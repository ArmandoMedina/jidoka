#Requires -Version 5
# verificar.ps1 - El gate local de Jidoka (Andon). Jidoka corre su propio Andon
# sobre si mismo (dogfooding). Lee la ley unica tools/blast-radius.json y hace
# cumplir el radio de impacto: si tocas un area, su doc dueno se toca en el mismo
# cambio.
#   BLOQUEA los doc_bloquea faltantes (exit 1); AVISA los doc_avisa (exit 0).
#   FALLA CERRADO (exit 2) si git no puede calcular el rango: un gate que no
#   puede medir no aprueba a ciegas.
# El hook local pre-push lo dispara antes de cada push. Saltar a proposito:
# git push --no-verify. El muro real es el required check server-side (CI).
#
# Uso:  ./tools/verificar.ps1                        (local: upstream...HEAD o working tree)
#       ./tools/verificar.ps1 -Base origin/main      (CI: rango del PR, base...HEAD)
#       ./tools/verificar.ps1 -Cambiados a.md,b.md   (prueba: lista inyectada, sin git)
#       -BorradosInyectados x.ps1                    (prueba: borrados inyectados, con -Cambiados)
#       -AgregadosInyectados docs/decisions/0099.md  (prueba: agregados inyectados, con -Cambiados)
#       -Manifiesto <ruta>                           (prueba/CI: manifiesto alterno)
#       -Repo <ruta>                                 (CI: raiz del repo, si el script corre copiado fuera de tools/)
# Nota: archivo ASCII a proposito (sin acentos) para no depender del BOM en PS 5.1.

param(
  [string]$Base = '',
  [string[]]$Cambiados = @(),
  [string[]]$BorradosInyectados = @(),
  [string[]]$AgregadosInyectados = @(),
  [string]$Manifiesto = '',
  [string]$Repo = ''
)

$ErrorActionPreference = 'Continue'
if (-not $Repo) { $Repo = Split-Path -Parent $PSScriptRoot }
Push-Location $Repo
$script:warn = 0
$script:block = 0

function Note($msg)  { Write-Host "  [AVISO] $msg"   -ForegroundColor Yellow; $script:warn++ }
function Block($msg) { Write-Host "  [BLOQUEA] $msg" -ForegroundColor Red;    $script:block++ }
function Ok($msg)    { Write-Host "  [OK] $msg"      -ForegroundColor Green }
function Fail($msg) {
  # Falla CERRADO: si el gate no puede medir, no aprueba (exit 2, distinto del bloqueo).
  Write-Host "  [ERROR] $msg" -ForegroundColor Red
  Write-Host ""
  Write-Host "== Gate sin veredicto: FALLA CERRADO (exit 2). Un muro que ante fallo interno se abre no es muro. ==" -ForegroundColor Red
  Pop-Location
  exit 2
}

function Test-Pattern($path, $pattern) {
  if ($pattern -notlike '*/*' -and $path -like '*/*') { return $false }
  return ($path -like $pattern)
}
function Match-Any($list, $pattern) {
  foreach ($item in $list) { if (Test-Pattern $item $pattern) { return $true } }
  return $false
}

Write-Host "== Verificar (Jidoka Andon; ley tools/blast-radius.json) =="

# $eliminados: los BORRADOS del mismo rango (--diff-filter=D), para el salvavidas
# no-borres-el-motor. $adiciones: los AGREGADOS (--diff-filter=A), para que "ADR
# nuevo" signifique nuevo DE VERDAD (issue #88: un ADR meramente editado o borrado
# no destraba el borrado del motor). Ojo PS 5.1: las variables NO pueden llamarse
# $borrados/$agregados (case-insensitive: pisarian los params *Inyectados). Si la
# llamada git secundaria falla NO es Fail (el rango ya se valido con la principal).
$eliminados = @()
$adiciones = @()
if ($Cambiados.Count -gt 0) {
  $changed = $Cambiados
  $eliminados = $BorradosInyectados
  $adiciones = $AgregadosInyectados
}
elseif ($Base) {
  $changed = git diff --name-only "$Base...HEAD" 2>$null
  if ($LASTEXITCODE -ne 0) { Fail "no pude calcular el rango $Base...HEAD (base inexistente o historia incompleta)" }
  $eliminados = git diff --name-only --diff-filter=D "$Base...HEAD" 2>$null
  if ($LASTEXITCODE -ne 0) { $eliminados = @() }
  $adiciones = git diff --name-only --diff-filter=A "$Base...HEAD" 2>$null
  if ($LASTEXITCODE -ne 0) { $adiciones = @() }
}
else {
  $upstream = git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>$null
  if ($LASTEXITCODE -eq 0) {
    # 3 puntos (merge-base), consistente con el CI: mide MIS cambios, no los del upstream.
    $changed = git diff --name-only '@{u}...HEAD' 2>$null
    if ($LASTEXITCODE -ne 0) { Fail "no pude calcular el rango @{u}...HEAD" }
    $eliminados = git diff --name-only --diff-filter=D '@{u}...HEAD' 2>$null
    if ($LASTEXITCODE -ne 0) { $eliminados = @() }
    $adiciones = git diff --name-only --diff-filter=A '@{u}...HEAD' 2>$null
    if ($LASTEXITCODE -ne 0) { $adiciones = @() }
  }
  else {
    # Sin upstream (rama nueva): solo se ve el working tree. Limite conocido:
    # el primer push de una rama nueva no se verifica aqui; lo cubre el CI en el PR.
    $changed = git diff --name-only HEAD 2>$null
    if ($LASTEXITCODE -ne 0) { Fail "no pude leer el working tree (git diff HEAD)" }
    $eliminados = git diff --name-only --diff-filter=D HEAD 2>$null
    if ($LASTEXITCODE -ne 0) { $eliminados = @() }
    $adiciones = git diff --name-only --diff-filter=A HEAD 2>$null
    if ($LASTEXITCODE -ne 0) { $adiciones = @() }
  }
}

if (-not $Manifiesto) { $Manifiesto = "$PSScriptRoot/blast-radius.json" }
if (-not (Test-Path $Manifiesto)) { Fail "no encuentro la ley ($Manifiesto)" }
$manifest = Get-Content $Manifiesto -Raw | ConvertFrom-Json
if (-not $manifest) { Fail "la ley ($Manifiesto) no parsea como JSON" }
$hayFalta = $false
$hayAviso = $false

foreach ($entry in $manifest) {
  $tocados = @()
  foreach ($f in $changed) {
    $enFuente = $false
    foreach ($pat in $entry.fuente) { if (Test-Pattern $f $pat) { $enFuente = $true; break } }
    if ($enFuente -and $entry.excluye) {
      foreach ($ex in $entry.excluye) { if (Test-Pattern $f $ex) { $enFuente = $false; break } }
    }
    if ($enFuente) { $tocados += $f }
  }
  if ($tocados.Count -eq 0) { continue }
  $quienes = ($tocados | Select-Object -First 3) -join ', '

  foreach ($tgt in $entry.doc_bloquea) {
    if (-not (Match-Any $changed $tgt)) {
      Block "[$($entry.nombre)] tocaste $quienes sin $tgt ($($entry.desc)). Rol: $($entry.rol)."
      $hayFalta = $true
    }
  }
  foreach ($tgt in $entry.doc_avisa) {
    if (-not (Match-Any $changed $tgt)) {
      $extra = ""; if ($entry.mensaje) { $extra = " $($entry.mensaje)." }
      Note "[$($entry.nombre)] tocaste $quienes; considera actualizar $tgt.$extra"
      $hayAviso = $true
    }
  }
  # product_avisa: sincronia del GRAFO de producto (capacidades, modulos, dominios),
  # no de un doc tecnico. Los targets son globs; si tocaste el area pero NINGUNA nota
  # de producto cambio en el mismo cambio, avisa una sola vez (baja fatiga).
  if ($entry.product_avisa -and $entry.product_avisa.Count -gt 0) {
    $tocoProducto = $false
    foreach ($tgt in $entry.product_avisa) { if (Match-Any $changed $tgt) { $tocoProducto = $true; break } }
    if (-not $tocoProducto) {
      $ej = ($entry.product_avisa | Select-Object -First 2) -join ', '
      Note "[$($entry.nombre)] tocaste $quienes sin tocar el grafo de producto (ej: $ej). Si la capacidad cambio, actualiza su nota en product/; si fue interno (refactor, perf), este aviso no es para ti."
      $hayAviso = $true
    }
  }
}

if (-not $hayFalta -and -not $hayAviso) { Ok "blast-radius al dia (o sin cambios en areas cubiertas)" }

# Salvavidas no-borres-el-motor (issue #73): la ley de arriba cubre TOCAR un area
# sin su doc dueno, pero no cubre BORRAR una pieza del motor (tools/*.ps1 o la ley
# misma). Un borrado asi solo pasa si el mismo cambio trae un ADR nuevo en
# docs/decisions/ (el indice README.md no cuenta: no es una decision nueva).
# Issue #88: "nuevo" = AGREGADO de verdad ($adiciones, --diff-filter=A). Un ADR
# meramente editado -- o peor, borrado -- NO destraba el borrado del motor.
$decisionesNuevas = @($adiciones | Where-Object { $_ -ne 'docs/decisions/README.md' })
$hayAdrNuevo = Match-Any $decisionesNuevas 'docs/decisions/*.md'
foreach ($del in @($eliminados | Where-Object { $_ })) {
  if (-not ((Test-Pattern $del 'tools/*.ps1') -or (Test-Pattern $del 'tools/blast-radius.json'))) { continue }
  if ($hayAdrNuevo) {
    Ok "[no-borres-el-motor] el cambio BORRA $del (pieza del motor) con un ADR nuevo en el mismo cambio: decision documentada"
  }
  else {
    Block "[no-borres-el-motor] el cambio BORRA $del (pieza del motor) sin un ADR nuevo en el mismo cambio: una decision se documenta, un accidente no. Restaurar es seguro (el archivo sigue en git); si es decision, escribe el ADR en docs/decisions/."
  }
}

# Contrato del HANDOFF (FLU-1, ADR 0045): el relevo se JALA (lo que la sesion
# entrante necesita), no se EMPUJA (el diario de la que sale). El contrato es dato
# de instancia en tools/flujo.json (clave 'handoff'); sin el archivo o sin la clave,
# el check no aplica (un repo sin el pilar de flujo no se bloquea). Es invariante de
# ESTADO, no de diff: se mide siempre -- la linea se para aunque este push no toque
# el HANDOFF (andon: el defecto se ataca donde se ve). Los limites: UNA seccion
# "Donde estamos", max_historicas secciones viejas, techo_lineas total; lo demas
# vive INTEGRO en el historico declarado (que /arranca nunca inyecta).
$flujoCfg = $null
if (Test-Path 'tools/flujo.json') {
  $flujoCfg = Get-Content 'tools/flujo.json' -Raw | ConvertFrom-Json
  if (-not $flujoCfg) { Fail "tools/flujo.json existe pero no parsea como JSON" }
}
if ($flujoCfg -and $flujoCfg.handoff -and (Test-Path 'HANDOFF.md')) {
  $oAcc = [char]0xF3   # 'o' acentuada: este motor es ASCII, el HANDOFF no
  # -Encoding UTF8 obligatorio: sin el, PS 5.1 lee el UTF-8 sin BOM como ANSI y
  # "Donde" acentuado se deforma -- el regex no casa y el contrato se mide en falso
  # (gotcha del recetario docs/guias/entorno-windows-powershell51.md, cazada en vivo).
  $hLineas = @(Get-Content 'HANDOFF.md' -Encoding UTF8)
  $nEstamos    = @($hLineas | Where-Object { $_ -match "^## D[o$oAcc]nde estamos" }).Count
  # Ancla de limite en el sufijo: 'Antes' debe ir seguido de fin de linea, espacio o
  # '(' -- si no, "## Antesala del proyecto" casaria por prefijo y contaria como
  # historica en falso (hallazgo #2). El grupo ([ (]|$) es explicito a proposito
  # (mas legible que un \b, que aqui tambien serviria tras la 's').
  $nHistoricas = @($hLineas | Where-Object { $_ -match "^## (D[o$oAcc]nde estuvimos|Antes)([ (]|$)" }).Count
  # Falla CERRADO ante config incompleta (hallazgo #1): sin max_historicas/techo_lineas
  # (o si no parsean como enteros no-negativos), [int]$null daria 0 y BLOQUEARIA TODO con
  # mensajes rotos. El JSON incompleto es tan invalido como el corrupto -> exit 2, no un
  # falso bloqueo. 'historico' ausente NO es motivo de Fail: usa el default de abajo.
  $maxParsed = 0; $techoParsed = 0
  $maxRaw   = $flujoCfg.handoff.max_historicas
  $techoRaw = $flujoCfg.handoff.techo_lineas
  if ($null -eq $maxRaw -or $null -eq $techoRaw -or
      -not [int]::TryParse([string]$maxRaw, [ref]$maxParsed) -or
      -not [int]::TryParse([string]$techoRaw, [ref]$techoParsed) -or
      $maxParsed -lt 0 -or $techoParsed -lt 0) {
    Fail "tools/flujo.json: la clave handoff esta incompleta (max_historicas/techo_lineas requeridas, enteros no-negativos). Sin ellas el contrato no se puede medir."
  }
  $maxHist  = $maxParsed
  $techoLin = $techoParsed
  $histDest = [string]$flujoCfg.handoff.historico
  if (-not $histDest) { $histDest = 'docs/handoff-historico.md' }
  $rotoHandoff = $false
  if ($nEstamos -eq 0) {
    Block "[contrato-handoff] el relevo perdio su seccion 'Donde estamos': el contrato exige exactamente UNA. Redacta el estado vigente bajo un encabezado '## Donde estamos'."
    $rotoHandoff = $true
  }
  if ($nEstamos -gt 1) {
    Block "[contrato-handoff] HANDOFF.md trae $nEstamos secciones 'Donde estamos'; el contrato admite UNA. Funde el estado vigente y archiva el resto INTEGRO en $histDest."
    $rotoHandoff = $true
  }
  if ($nHistoricas -gt $maxHist) {
    Block "[contrato-handoff] HANDOFF.md trae $nHistoricas secciones historicas ('Donde estuvimos'/'Antes'); el contrato admite $maxHist. Mueve las viejas INTEGRAS a $histDest (ese archivo no se inyecta al abrir)."
    $rotoHandoff = $true
  }
  if ($hLineas.Count -gt $techoLin) {
    Block "[contrato-handoff] HANDOFF.md mide $($hLineas.Count) lineas; el techo del contrato es $techoLin (tools/flujo.json). El relevo se jala, no se empuja: poda o archiva en $histDest."
    $rotoHandoff = $true
  }
  if (-not $rotoHandoff) { Ok "[contrato-handoff] HANDOFF.md dentro de contrato ($nHistoricas/$maxHist historicas, $($hLineas.Count)/$techoLin lineas)" }
}

# Costura .local: extension de mecanica ESPECIFICA del repo (p.ej. lint/tests de un
# lenguaje: ruff, pytest). El motor generico NO se bifurca -- el hijo pone sus checks
# aqui y siguen contando para $script:warn / $script:block (usa Note/Block/Ok). Es la
# via sostenible para customizar sin romper -Actualizar. Ausente -> se ignora (la
# mayoria de repos no la necesita). Ve $changed y las funciones del gate por dot-source.
$local = Join-Path $PSScriptRoot 'verificar.local.ps1'
if (Test-Path -LiteralPath $local) {
  Write-Host "== Extension local del gate (tools/verificar.local.ps1) =="
  . $local
}

Write-Host ""
if ($script:block -gt 0) {
  Write-Host "== $($script:block) bloqueo(s). PUSH DETENIDO. ==" -ForegroundColor Red
  Write-Host "   Sincroniza los docs duenos y reintenta, o 'git push --no-verify' a proposito." -ForegroundColor Red
  Pop-Location
  exit 1
}
elseif ($script:warn -gt 0) {
  Write-Host "== $($script:warn) aviso(s) no bloqueante(s). Revisalos antes de subir. ==" -ForegroundColor Yellow
  Pop-Location
  exit 0
}
else { Write-Host "== Todo limpio. ==" -ForegroundColor Green; Pop-Location; exit 0 }
