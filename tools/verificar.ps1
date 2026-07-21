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

# Contrato del ROADMAP (FLU-1, ADR 0045): el ROADMAP es una cola de trabajo
# CLASIFICADA, no un diario. Espejo del contrato del HANDOFF -- misma semantica de
# falla-cerrado, mismo caracter de invariante de ESTADO (no de diff): se mide siempre.
# Solo aplica si flujo.json trae la clave 'roadmap' y existe ROADMAP.md (un repo sin el
# pilar de flujo no se bloquea). Las unicas secciones legales son las clases de servicio
# (Urgente/Con fecha/Normal/Algun dia) mas Referencia (landscape, sin contrato de item);
# cada item vivo declara [alta:] (+ apetito/vence segun su clase). El detalle vive en el
# historico declarado (roadmap-historico.md) o en su doc dueno; el techo lo impide crecer.
if ($flujoCfg -and $flujoCfg.roadmap -and (Test-Path 'ROADMAP.md')) {
  $uAcc = [char]0xFA   # 'u' acentuada: Algun -> Algún (este motor es ASCII, el ROADMAP no)
  $iAcc = [char]0xED   # 'i' acentuada: dia -> día
  # -Encoding UTF8 obligatorio, mismo gotcha que el HANDOFF: sin el, PS 5.1 lee el UTF-8
  # sin BOM como ANSI y 'Algún día' se deforma -- el regex no casa y el contrato se mide
  # en falso (recetario docs/guias/entorno-windows-powershell51.md).
  $rLineas = @(Get-Content 'ROADMAP.md' -Encoding UTF8)
  # Falla CERRADO ante config incompleta (mismo criterio que el handoff): techo_lineas
  # requerida y entera no-negativa, o exit 2. 'historico' ausente NO es Fail: usa default.
  $rTechoParsed = 0
  $rTechoRaw = $flujoCfg.roadmap.techo_lineas
  if ($null -eq $rTechoRaw -or
      -not [int]::TryParse([string]$rTechoRaw, [ref]$rTechoParsed) -or
      $rTechoParsed -lt 0) {
    Fail "tools/flujo.json: la clave roadmap esta incompleta (techo_lineas requerida, entero no-negativo). Sin ella el contrato no se puede medir."
  }
  $rTecho = $rTechoParsed
  $rHist = [string]$flujoCfg.roadmap.historico
  if (-not $rHist) { $rHist = 'docs/roadmap-historico.md' }
  $rPermitidas = "Urgente, Con fecha, Normal, Alg${uAcc}n d${iAcc}a, Referencia"
  $rotoRoadmap = $false
  $nItems = 0
  $claseActual = $null   # clase de la seccion en curso ($null = ninguna/ilegal: no clasifica items)
  foreach ($ln in $rLineas) {
    if ($ln -match '^## (.+)$') {
      $secTexto = $matches[1].Trim()
      # Fold de acentos ('Algún día'/'Algun dia' -> 'algun dia') y a minusculas: acepta
      # la clase con y sin acento.
      $secClave = ($secTexto -replace $uAcc,'u' -replace $iAcc,'i').ToLowerInvariant()
      $clase = $null
      switch ($secClave) {
        'urgente'    { $clase = 'urgente' }
        'con fecha'  { $clase = 'confecha' }
        'normal'     { $clase = 'normal' }
        'algun dia'  { $clase = 'algundia' }
        'referencia' { $clase = 'referencia' }
      }
      if ($null -eq $clase) {
        Block "[contrato-roadmap] el ROADMAP es cola clasificada, no diario: seccion '$secTexto' fuera del contrato (permitidas: $rPermitidas); el detalle vive en el historico ($rHist) o en su doc dueno."
        $rotoRoadmap = $true
        $claseActual = $null
      }
      else { $claseActual = $clase }
      continue
    }
    # Solo items de nivel RAIZ ('^- '); los sub-bullets indentados ('^  - ') no cuentan.
    if ($ln -match '^- ') {
      if ($null -eq $claseActual -or $claseActual -eq 'referencia') { continue }
      $nItems++
      $rNombre = $ln.Trim()
      if ($rNombre.Length -gt 60) { $rNombre = $rNombre.Substring(0, 60) }
      $faltan = @()
      if ($ln -notmatch 'alta:\s*\d{4}-\d{2}-\d{2}') { $faltan += 'alta:AAAA-MM-DD' }
      if ($claseActual -eq 'urgente' -or $claseActual -eq 'confecha' -or $claseActual -eq 'normal') {
        if ($ln -notmatch 'apetito:\d+h') { $faltan += 'apetito:Nh' }
      }
      if ($claseActual -eq 'confecha' -and $ln -notmatch 'vence:\d{4}-\d{2}-\d{2}') { $faltan += 'vence:AAAA-MM-DD' }
      if ($faltan.Count -gt 0) {
        Block "[contrato-roadmap] el item '$rNombre' no declara su contrato: falta(n) $($faltan -join ', '). Todo item vivo trae [alta:AAAA-MM-DD] (Urgente/Con fecha/Normal ademas apetito:Nh; Con fecha ademas vence:AAAA-MM-DD)."
        $rotoRoadmap = $true
      }
    }
  }
  if ($rLineas.Count -gt $rTecho) {
    Block "[contrato-roadmap] ROADMAP.md mide $($rLineas.Count) lineas; el techo del contrato es $rTecho (tools/flujo.json). La cola se clasifica, no se acumula: poda lo cumplido a CHANGELOG.md o archiva en $rHist."
    $rotoRoadmap = $true
  }
  if (-not $rotoRoadmap) { Ok "[contrato-roadmap] ROADMAP.md dentro de contrato ($nItems items clasificados, $($rLineas.Count)/$rTecho lineas)" }
}

# Contrato del CHANGELOG (FLU-1, ADR 0045): el CHANGELOG es registro OPERATIVO, no
# una carta entregable. Se mide SOLO la seccion TOPE (del primer '## [' al siguiente
# '## [') -- NO es retroactivo: las versiones viejas quedan como historia. Solo aplica
# si flujo.json trae la clave 'changelog' y existe CHANGELOG.md (un repo sin el pilar
# no se bloquea). Reglas de la seccion tope: (a) header datado 'X.Y.Z <guion> AAAA-MM-DD'
# (semver + fecha; guion largo U+2014 o guion simple); (b) todo bullet raiz ('^- ')
# empieza con '- **' y un tipo permitido entre backticks o la palabra 'ADR ' (voz de la
# casa); (c) la prosa entre el header/subtitulo y el PRIMER bullet no pasa de
# max_prosa_lineas (los '### ' no cuentan). Config incompleta -> falla cerrado (exit 2).
if ($flujoCfg -and $flujoCfg.changelog -and (Test-Path 'CHANGELOG.md')) {
  $emDash = [char]0x2014   # guion largo: el header lo usa; se acepta tambien guion simple
  $btick  = [char]0x60     # backtick: el tipo va entre backticks (- **`feat` ...)
  # Falla CERRADO ante config incompleta (mismo criterio que handoff/roadmap): 'tipos'
  # no-vacio y max_prosa_lineas entero no-negativo, o exit 2.
  $tiposChg = @($flujoCfg.changelog.tipos | Where-Object { $_ })
  $prosaParsed = 0
  $prosaRaw = $flujoCfg.changelog.max_prosa_lineas
  if ($tiposChg.Count -eq 0 -or $null -eq $prosaRaw -or
      -not [int]::TryParse([string]$prosaRaw, [ref]$prosaParsed) -or
      $prosaParsed -lt 0) {
    Fail "tools/flujo.json: la clave changelog esta incompleta (tipos no-vacio y max_prosa_lineas entero no-negativo requeridos). Sin ellos el contrato no se puede medir."
  }
  $maxProsa = $prosaParsed
  # -Encoding UTF8 obligatorio (mismo gotcha de acentos/guion largo que handoff/roadmap):
  # sin el, PS 5.1 lee el UTF-8 sin BOM como ANSI y el guion largo del header no casa.
  $cLineas = @(Get-Content 'CHANGELOG.md' -Encoding UTF8)
  # Localiza la seccion TOPE: del primer '## [' al siguiente '## ['. Los subtitulos '### '
  # y las menciones '## [' a media linea (dentro de backticks) NO son frontera (^ ancla).
  $iStart = -1
  for ($i = 0; $i -lt $cLineas.Count; $i++) {
    if ($cLineas[$i] -match '^## \[') { $iStart = $i; break }
  }
  if ($iStart -ge 0) {
    $iEnd = $cLineas.Count
    for ($i = $iStart + 1; $i -lt $cLineas.Count; $i++) {
      if ($cLineas[$i] -match '^## \[') { $iEnd = $i; break }
    }
    $rotoChangelog = $false
    # (a) header datado. El guion es U+2014 o '-'; grupo explicito a proposito.
    $ver = ''
    if ($cLineas[$iStart] -match "^## \[(\d+\.\d+\.\d+)\] ($emDash|-) \d{4}-\d{2}-\d{2}") {
      $ver = $matches[1]
    }
    else {
      $hdr = $cLineas[$iStart].Trim()
      if ($hdr.Length -gt 60) { $hdr = $hdr.Substring(0, 60) }
      Block "[contrato-changelog] la seccion tope no cumple el header 'X.Y.Z $emDash AAAA-MM-DD' (semver + fecha): '$hdr'. El registro se data."
      $rotoChangelog = $true
    }
    # (b) bullets raiz tipados. El tipo va entre backticks; 'ADR ' es voz de la casa.
    $tipoAlt = ($tiposChg | ForEach-Object { [regex]::Escape([string]$_) }) -join '|'
    $bulletPat = "^- \*\*($btick($tipoAlt)$btick|ADR )"
    # (c) prosa: el primer bullet raiz cierra la ventana de prosa.
    $iPrimerBullet = -1
    for ($i = $iStart; $i -lt $iEnd; $i++) {
      if ($cLineas[$i] -match '^- ') { $iPrimerBullet = $i; break }
    }
    $nBullets = 0
    for ($i = $iStart; $i -lt $iEnd; $i++) {
      $ln = $cLineas[$i]
      if ($ln -notmatch '^- ') { continue }
      if ($ln -match $bulletPat) { $nBullets++; continue }
      $cNombre = $ln.Trim()
      if ($cNombre.Length -gt 60) { $cNombre = $cNombre.Substring(0, 60) }
      Block "[contrato-changelog] el bullet '$cNombre' no declara su tipo: todo bullet raiz empieza con '- **' y un tipo permitido entre backticks ($($tiposChg -join ', ')) o 'ADR '. El changelog es registro tipado."
      $rotoChangelog = $true
    }
    $limiteProsa = if ($iPrimerBullet -ge 0) { $iPrimerBullet } else { $iEnd }
    $nProsa = 0
    for ($i = $iStart + 1; $i -lt $limiteProsa; $i++) {
      $ln = $cLineas[$i]
      if ($ln.Trim() -eq '') { continue }
      if ($ln -match '^#') { continue }   # subtitulos '### ' (o mas profundos) no son prosa
      $nProsa++
    }
    if ($nProsa -gt $maxProsa) {
      Block "[contrato-changelog] la seccion tope trae $nProsa lineas de prosa antes del primer bullet; el techo es $maxProsa (tools/flujo.json). El changelog es registro operativo, no carta: comprime la prosa (mueve el detalle a sub-bullets tipados)."
      $rotoChangelog = $true
    }
    if (-not $rotoChangelog) { Ok "[contrato-changelog] seccion [$ver] dentro de contrato ($nBullets bullets tipados, prosa $nProsa/$maxProsa)" }
  }
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
