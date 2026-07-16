#Requires -Version 5
# instalar.ps1 - El instalador minimo de Jidoka (Sprint 3, Fase 3.A). Siembra el
# metodo (ritual + motor Andon) en un repo destino. MVP Windows-first (ADR 0008):
# lee el motor GENERICO del propio arbol de Jidoka y lo copia -- NO duplica la ley
# (verificar.ps1 y auditar.ps1 ya son data-driven). Solo la ley se siembra desde
# una PLANTILLA por arquetipo. El npx jidoka-method (npm, cross-platform) es una
# fase posterior; ver ROADMAP.
#
# Regla dura: NO CLOBBER. Nunca sobrescribe un archivo existente en el destino
# (lo salta y lo reporta) -- instalar sobre un repo con trabajo no borra nada.
#
# Uso:
#   ./tools/instalar.ps1 -Destino C:\ruta\repo-limpio                 (instalar)
#   ./tools/instalar.ps1 -Destino ... -Arquetipo docs-as-code -Yes    (instalar sin prompt)
#   ./tools/instalar.ps1 -Destino ... -Actualizar                     (bajar la mecanica al hijo)
#   ./tools/instalar.ps1 -Destino ... -Sellar                         (sellar un hijo que convergio a mano)
# Nota: archivo ASCII a proposito (sin acentos) para PS 5.1.

[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)][string]$Destino,
  [string]$Arquetipo = '',   # vacio = no se paso: pregunta interactivo (o docs-as-code con -Yes)
  [switch]$Yes,
  [switch]$Actualizar,
  [switch]$Sellar
)

$ErrorActionPreference = 'Stop'
$jidoka = Split-Path -Parent $PSScriptRoot   # raiz de Jidoka (padre de tools/)
$script:copiados = 0
$script:saltados = 0
$script:stubs = 0

function Info($m) { Write-Host "  $m" }
function Ok($m)   { Write-Host "  [OK] $m"   -ForegroundColor Green }
function Skip($m) { Write-Host "  [SALTA] $m (ya existe; no se sobrescribe)" -ForegroundColor Yellow }
function Die($m)  { Write-Host "[ERROR] $m" -ForegroundColor Red; exit 1 }

# Copia un archivo si el destino NO existe (no clobber). Crea el directorio padre.
function Copy-Safe($src, $dst) {
  if (Test-Path -LiteralPath $dst) { Skip $dst; $script:saltados++; return }
  $parent = Split-Path -Parent $dst
  if ($parent -and -not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
  Copy-Item -LiteralPath $src -Destination $dst -Force
  $script:copiados++
}

# Copia un directorio recursivo, archivo por archivo, respetando no-clobber.
function Copy-DirSafe($srcDir, $dstDir) {
  Get-ChildItem -LiteralPath $srcDir -Recurse -File | ForEach-Object {
    $rel = $_.FullName.Substring($srcDir.Length).TrimStart('\', '/')
    Copy-Safe $_.FullName (Join-Path $dstDir $rel)
  }
}

# SHA256 del CONTENIDO NORMALIZADO A LF (sin CR): el hash es AGNOSTICO al fin de
# linea. Sin esto, un hijo con politica eol=lf (working tree en LF) diverge de un
# Jidoka con eol=crlf en TODAS las piezas, para siempre -- el three-way compara
# hash(LF) vs seed(CRLF) y nunca casan (defecto cazado al bajar a tracker-financiero;
# ADR 0021). El motor es 100% texto; normalizar quitando 0x0D es seguro aqui.
function Get-MotorHash($path) {
  $bytes = [System.IO.File]::ReadAllBytes($path)
  $sinCR = New-Object System.Collections.Generic.List[byte]
  foreach ($b in $bytes) { if ($b -ne 13) { $sinCR.Add($b) } }
  $sha = [System.Security.Cryptography.SHA256]::Create()
  try { $h = $sha.ComputeHash($sinCR.ToArray()) } finally { $sha.Dispose() }
  return ([System.BitConverter]::ToString($h) -replace '-', '')
}

# Aplana una entrada de motor a pares { rel = ruta relativa con '/'; src = ruta
# absoluta en el arbol de ORIGEN ($root) }. No filtra por existencia en destino:
# es la lista de piezas que la entrada cubre, con la FUENTE como verdad.
function Get-MotorPares($entry, $root) {
  $srcRoot = Join-Path $root $entry.origen
  $pares = @()
  if (-not (Test-Path -LiteralPath $srcRoot)) { return $pares }
  if ($entry.dir) {
    Get-ChildItem -LiteralPath $srcRoot -Recurse -File | ForEach-Object {
      $relEnOrigen = $_.FullName.Substring($srcRoot.Length).TrimStart('\', '/').Replace('\', '/')
      $relDst = ($entry.destino.Replace('\', '/')).TrimEnd('/') + '/' + $relEnOrigen
      $pares += [pscustomobject]@{ rel = $relDst; src = $_.FullName }
    }
  } else {
    $pares += [pscustomobject]@{ rel = $entry.destino.Replace('\', '/'); src = $srcRoot }
  }
  return $pares
}

# Clasifica cada pieza de mecanica del manifiesto comparando el archivo del hijo
# (en $Destino) contra la FUENTE de Jidoka, con el mismo hasheo agnostico-al-EOL:
#   - hijo == Jidoka  -> PRISTINA:    entra en la semilla con el hash de Jidoka.
#   - hijo != Jidoka  -> CUSTOMIZADA: se OMITE (el -Actualizar la vera DIVERGE y la preserva).
#   - hijo ausente    -> se omite (el -Actualizar la agregara).
#   - rel en $excluir -> se salta (ni se sella ni se clasifica).
# Logica COMPARTIDA por -Sellar y por el sello de la instalacion limpia: ambos deben
# clasificar identico. Un brownfield con piezas customizadas (saltadas por no-clobber)
# NO debe registrar el hash del HIJO como semilla -- eso haria que un -Actualizar
# posterior viera hijo==semilla y PISARA la customizacion (perdida de datos; jidoka#36).
# Devuelve { seed = [ordered]; divergen = [] ; pristinas = int; ausentes = int }.
function Get-SelloClasificado($jidoka, $manif, $Destino, $excluir) {
  if (-not $excluir) { $excluir = @() }
  $seed = [ordered]@{}
  $divergen = @(); $pristinas = 0; $ausentes = 0
  foreach ($e in $manif.motor) {
    if ($e.clase -and $e.clase -ne 'mecanica') { continue }
    foreach ($par in (Get-MotorPares $e $jidoka)) {
      if ($excluir -contains $par.rel) { continue }
      $childAbs = Join-Path $Destino $par.rel
      if (-not (Test-Path -LiteralPath $childAbs)) { $ausentes++; continue }
      $jidokaHash = Get-MotorHash $par.src
      $childHash = Get-MotorHash $childAbs
      if ($childHash -eq $jidokaHash) {
        $seed[$par.rel] = $jidokaHash                                # pristina -> registrada
        $pristinas++
      } else {
        $divergen += $par.rel                                        # customizada -> omitida (se preservara)
      }
    }
  }
  return [pscustomobject]@{ seed = $seed; divergen = $divergen; pristinas = $pristinas; ausentes = $ausentes }
}

# ---------------------------------------------------------------------------
# Modo -Actualizar: re-siembra SOLO la mecanica (clase=mecanica) con conciencia
# de TRES VIAS por hash (estilo dpkg conffiles). Por cada archivo de motor:
#   - hijo ausente                       -> lo agrega (nuevo en esta version)
#   - hijo == Jidoka                     -> al dia (no toca)
#   - hijo == hash sembrado (no lo toco) -> lo actualiza a la version de Jidoka
#   - hijo != hash sembrado (lo customizo) -> DIVERGENCIA: NO pisa; escribe
#                                             <archivo>.jidoka-nuevo y lo reporta
# La INSTANCIA (ley, stubs, product/, HANDOFF, ADRs) nunca se toca: solo se itera
# 'motor'. El sello registra la version de Jidoka a la que se sincronizo y, por
# archivo, el hash que Jidoka ENVIA ahora (para el siguiente -Actualizar).
function Invoke-Actualizar($jidoka, $manif, $Destino, $utf8) {
  $selloDst = Join-Path $Destino 'tools/jidoka-motor.json'
  if (-not (Test-Path -LiteralPath $selloDst)) {
    Die "no hay sello (tools/jidoka-motor.json) en '$Destino': no parece un hijo instalado. Usa la instalacion normal (sin -Actualizar)."
  }
  $sello = Get-Content $selloDst -Raw | ConvertFrom-Json
  $seed = @{}
  if ($sello.sembrado_hashes) {
    foreach ($p in $sello.sembrado_hashes.PSObject.Properties) { $seed[$p.Name] = $p.Value }
  }
  # Lista de EXCLUSION del hijo: piezas de mecanica que el hijo declara que NO quiere
  # (p.ej. un lab que hace back-out de probar-gate/andon.yml por incompatibles). El lazo
  # las respeta: no las re-agrega ni las toca. Cierra la friccion recurrente del drift
  # estructural (el hijo repetia el mismo back-out en cada bajada; ADR 0022).
  $excluir = @()
  if ($sello.excluir) { $excluir = @($sello.excluir) }
  $versionPath = Join-Path $jidoka 'tools/version.txt'
  $versionNueva = if (Test-Path $versionPath) { (Get-Content $versionPath -Raw).Trim() } else { 'desconocida' }

  Write-Host "== Actualizar motor: hijo en Jidoka $($sello.version) -> Jidoka $versionNueva =="
  if ($sello.version -eq $versionNueva) { Info "(el sello ya declara $versionNueva; re-checando piezas por si cambiaron)" }

  $nuevoSeed = [ordered]@{}
  $alDia = 0; $agregados = 0; $actualizados = 0; $divergen = @(); $excluidas = 0

  # Limite conocido (estilo dpkg): -Actualizar re-siembra el motor ACTUAL de Jidoka.
  # NO borra piezas que una version futura de Jidoka haya retirado -- un archivo viejo
  # sigue en el hijo y cae del sello sin aviso. Removerlas es decision aparte (arriesga
  # pisar algo que el hijo aun usa); por ahora se prefiere no borrar.
  foreach ($e in $manif.motor) {
    if ($e.clase -and $e.clase -ne 'mecanica') { continue }        # solo la mecanica converge
    $srcRoot = Join-Path $jidoka $e.origen
    if (-not (Test-Path -LiteralPath $srcRoot)) { continue }        # origen ausente en Jidoka: nada que sembrar

    # Aplana la entrada a pares (rel, origen-abs) usando el arbol de Jidoka como verdad.
    $pares = @()
    if ($e.dir) {
      Get-ChildItem -LiteralPath $srcRoot -Recurse -File | ForEach-Object {
        $relEnOrigen = $_.FullName.Substring($srcRoot.Length).TrimStart('\', '/').Replace('\', '/')
        $relDst = ($e.destino.Replace('\', '/')).TrimEnd('/') + '/' + $relEnOrigen
        $pares += [pscustomobject]@{ rel = $relDst; src = $_.FullName }
      }
    } else {
      $pares += [pscustomobject]@{ rel = $e.destino.Replace('\', '/'); src = $srcRoot }
    }

    foreach ($par in $pares) {
      if ($excluir -contains $par.rel) {                           # 0. el hijo la excluyo -> ni se re-agrega ni se toca
        Write-Host "  [EXCLUIDA] $($par.rel) (el hijo la excluyo del motor)" -ForegroundColor DarkGray; $excluidas++
        continue
      }
      $jidokaHash = Get-MotorHash $par.src
      $childAbs = Join-Path $Destino $par.rel
      $nuevoSeed[$par.rel] = $jidokaHash                            # el sello guarda lo que Jidoka ENVIA ahora

      if (-not (Test-Path -LiteralPath $childAbs)) {               # 1. nuevo en esta version
        $parent = Split-Path -Parent $childAbs
        if ($parent -and -not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
        Copy-Item -LiteralPath $par.src -Destination $childAbs -Force
        Write-Host "  [NUEVO]  $($par.rel)" -ForegroundColor Green; $agregados++
        continue
      }
      $childHash = Get-MotorHash $childAbs
      if ($childHash -eq $jidokaHash) { $alDia++; continue }        # 2. al dia
      $seedHash = $seed[$par.rel]
      if ($seedHash -and $childHash -eq $seedHash) {                # 3. el hijo no lo toco -> actualiza
        Copy-Item -LiteralPath $par.src -Destination $childAbs -Force
        Write-Host "  [ACTUALIZA] $($par.rel)" -ForegroundColor Cyan; $actualizados++
        continue
      }
      # 4. DIVERGENCIA: el hijo lo customizo. No se pisa; se deja la version de Jidoka al lado.
      $nuevoPath = "$childAbs.jidoka-nuevo"
      Copy-Item -LiteralPath $par.src -Destination $nuevoPath -Force
      Write-Host "  [DIVERGE] $($par.rel) -> se dejo $($par.rel).jidoka-nuevo (revisa a mano)" -ForegroundColor Yellow
      $divergen += $par.rel
    }
  }

  # Cosecha #7 (issue #86): -Actualizar es consciente de migraciones. La mecanica que
  # baja puede asumir piezas de instancia nuevas (el arranca 1.16+ inyecta
  # product/PRODUCT_BRIEF.md, product/infra.md y CONTRIBUTING.md): los stubs del
  # manifiesto que el hijo NO tiene se siembran en la misma pasada (no-clobber estricto:
  # lo existente jamas se toca). Lo condicionado a arquetipo solo se decide si el sello
  # lo registra (sellos 1.17+); con sello viejo se avisa y se revisa a mano.
  $migrados = 0
  $stubsMigra = @($manif.stubs | Where-Object { $_ })
  if ($sello.producto -and $manif.stubs_arquetipo.($sello.producto)) { $stubsMigra += $manif.stubs_arquetipo.($sello.producto) }
  if ($sello.gobernanza -and $manif.stubs_arquetipo.gobernanza) { $stubsMigra += $manif.stubs_arquetipo.gobernanza }
  foreach ($s in $stubsMigra) {
    $dst = Join-Path $Destino $s.ruta
    if (Test-Path -LiteralPath $dst) { continue }
    $parent = Split-Path -Parent $dst
    if ($parent -and -not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
    [System.IO.File]::WriteAllText($dst, $s.contenido, $utf8)
    Write-Host "  [MIGRA] $($s.ruta) sembrado: el motor nuevo lo asume y el hijo no lo tenia" -ForegroundColor Green
    $migrados++
  }
  if (-not $sello.producto -and @($manif.stubs_arquetipo.PSObject.Properties).Count) {
    Write-Host "  [MIGRA] el sello no registra el arquetipo (pre-1.17): los stubs por-arquetipo no se auto-siembran; si te falta la semilla del QUE, revisa stubs_arquetipo del manifiesto a mano" -ForegroundColor Yellow
  }

  # Actualiza el sello: version nueva + los hashes que Jidoka envia ahora. Preserva la
  # lista de exclusion del hijo y el arquetipo registrado (no se pierden entre bajadas).
  $selloNuevo = [ordered]@{ version = $versionNueva; sembrado_hashes = $nuevoSeed }
  if ($sello.producto) { $selloNuevo.producto = $sello.producto }
  if ($sello.gobernanza) { $selloNuevo.gobernanza = $true }
  if ($excluir.Count) { $selloNuevo.excluir = $excluir }
  [System.IO.File]::WriteAllText($selloDst, (($selloNuevo | ConvertTo-Json -Depth 5) + "`n"), $utf8)

  Write-Host ""
  $resumen = "== Motor: $alDia al dia | $actualizados actualizado(s) | $agregados nuevo(s) | $($divergen.Count) divergen"
  if ($excluidas) { $resumen += " | $excluidas excluida(s)" }
  if ($migrados) { $resumen += " | $migrados stub(s) migrado(s)" }
  Write-Host "$resumen ==" -ForegroundColor Green
  if ($divergen.Count -gt 0) {
    Write-Host "Divergencias (el hijo customizo estas piezas de mecanica; se preservaron):" -ForegroundColor Yellow
    foreach ($d in $divergen) { Write-Host "  - $d  (compara con $d.jidoka-nuevo)" -ForegroundColor Yellow }
    Write-Host "  Reconcilia a mano: adopta el .jidoka-nuevo o mueve tu ajuste a la costura .local." -ForegroundColor Yellow
  }
  Write-Host "Instancia (ley, product/, HANDOFF, ADRs) intacta: lo existente no se toca; solo se sembro lo que el motor nuevo asume y faltaba ([MIGRA])." -ForegroundColor Cyan
  Write-Host "Siguiente: revisa el diff en una rama y abrelo como PR (el diff ES la revision)." -ForegroundColor Cyan
}

# ---------------------------------------------------------------------------
# Modo -Sellar: escribe el sello INICIAL de un hijo que ya tiene el motor pero
# convergio a mano (sin sello), CLASIFICANDO cada pieza de mecanica:
#   - hijo == Jidoka actual  -> PRISTINA: la registra en la semilla con el hash
#     de Jidoka (asi el proximo -Actualizar la actualiza como al dia/actualiza).
#   - hijo != Jidoka         -> CUSTOMIZADA: NO la registra (semilla sin ella) ->
#     el proximo -Actualizar la vera DIVERGE (child != seed=null) y la PRESERVA.
#   - hijo ausente           -> se omite (el -Actualizar la agregara).
# Generaliza el arreglo manual que se hizo a mano en los labs (SGI: quitar las
# entradas code-first; TF: semilla vacia): en vez de asumir pristina (el bug que
# casi pisa el motor de SGI) o preservar todo (semilla vacia, que no actualiza lo
# pristino), clasifica pieza por pieza. La instancia nunca se toca.
function Invoke-Sellar($jidoka, $manif, $Destino, $utf8) {
  $selloDst = Join-Path $Destino 'tools/jidoka-motor.json'
  $versionPath = Join-Path $jidoka 'tools/version.txt'
  $version = if (Test-Path $versionPath) { (Get-Content $versionPath -Raw).Trim() } else { 'desconocida' }

  Write-Host "== Sellar motor: clasifica cada pieza pristina-vs-customizada (Jidoka $version) =="
  # Preserva la lista de exclusion del hijo si ya existia (re-sellar no la pierde).
  $excluir = @()
  if (Test-Path -LiteralPath $selloDst) {
    Info "(ya hay un sello; se re-clasifica y sobrescribe)"
    $selloViejo = Get-Content $selloDst -Raw | ConvertFrom-Json
    if ($selloViejo.excluir) { $excluir = @($selloViejo.excluir) }
  }

  # Clasifica pieza por pieza con la logica compartida (misma que usa el sello de la
  # instalacion limpia): pristina -> semilla; customizada -> omitida (se preservara).
  $clasif = Get-SelloClasificado $jidoka $manif $Destino $excluir
  $seed = $clasif.seed
  $pristinas = $clasif.pristinas; $divergen = $clasif.divergen; $ausentes = $clasif.ausentes

  $selloNuevo = [ordered]@{ version = $version; sembrado_hashes = $seed }
  if ($excluir.Count) { $selloNuevo.excluir = $excluir }
  $parent = Split-Path -Parent $selloDst
  if ($parent -and -not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
  [System.IO.File]::WriteAllText($selloDst, (($selloNuevo | ConvertTo-Json -Depth 5) + "`n"), $utf8)

  Write-Host ""
  Write-Host "== Sello escrito: $pristinas pristina(s) registrada(s) | $($divergen.Count) divergen (se preservaran) | $ausentes ausente(s) ==" -ForegroundColor Green
  if ($divergen.Count -gt 0) {
    Write-Host "Piezas customizadas (NO registradas en la semilla -> -Actualizar las preservara):" -ForegroundColor Yellow
    foreach ($d in $divergen) { Write-Host "  - $d" -ForegroundColor Yellow }
  }
  Write-Host "Sello: tools/jidoka-motor.json (version $version). Siguiente: -Actualizar baja lo pristino, preserva lo customizado." -ForegroundColor Cyan
}

$utf8 = New-Object System.Text.UTF8Encoding($false)

# 1. Leer el manifiesto de siembra.
$manifPath = Join-Path $jidoka 'kit/.jidoka/instalar/manifiesto.json'
if (-not (Test-Path $manifPath)) { Die "no encuentro el manifiesto ($manifPath)" }
$manif = Get-Content $manifPath -Raw | ConvertFrom-Json

# Modo -Actualizar: re-siembra SOLO la mecanica sobre un hijo ya instalado, y termina.
if ($Actualizar) {
  if (-not (Test-Path -LiteralPath $Destino)) { Die "el destino '$Destino' no existe (para -Actualizar debe ser un hijo ya instalado)" }
  $Destino = (Resolve-Path -LiteralPath $Destino).Path
  if ($Destino -eq $jidoka) { Die "el destino no puede ser el propio repo de Jidoka" }
  Invoke-Actualizar $jidoka $manif $Destino $utf8
  exit 0
}

# Modo -Sellar: escribe el sello inicial (clasificando pristina-vs-customizada) de un
# hijo que ya tiene el motor pero convergio a mano sin sello. Y termina.
if ($Sellar) {
  if (-not (Test-Path -LiteralPath $Destino)) { Die "el destino '$Destino' no existe (para -Sellar debe ser un hijo con el motor ya presente)" }
  $Destino = (Resolve-Path -LiteralPath $Destino).Path
  if ($Destino -eq $jidoka) { Die "el destino no puede ser el propio repo de Jidoka" }
  Invoke-Sellar $jidoka $manif $Destino $utf8
  exit 0
}

# 2. Resolver el arquetipo. Si no se paso: pregunta interactivo (o docs-as-code con -Yes).
#    Antes tenia un default silencioso 'docs-as-code' -- un repo code-first recibia el
#    arquetipo equivocado sin enterarse. Ahora se pregunta salvo que corras desatendido.
if (-not $Arquetipo) {
  $disp = @($manif.arquetipos.PSObject.Properties | Where-Object { $_.Value.disponible })
  if ($Yes) {
    $Arquetipo = 'docs-as-code'   # desatendido: default explicito
  }
  else {
    Write-Host "== Elige el arquetipo (que siembra Jidoka) =="
    for ($i = 0; $i -lt $disp.Count; $i++) {
      Write-Host ("  [{0}] {1} - {2}" -f ($i + 1), $disp[$i].Name, $disp[$i].Value.desc)
    }
    $sel = Read-Host "Numero o nombre (Enter = docs-as-code)"
    if (-not $sel) { $Arquetipo = 'docs-as-code' }
    elseif ($sel -match '^\d+$' -and [int]$sel -ge 1 -and [int]$sel -le $disp.Count) { $Arquetipo = $disp[[int]$sel - 1].Name }
    else { $Arquetipo = $sel.Trim() }
  }
}

Write-Host "== Instalador de Jidoka (arquetipo: $Arquetipo) =="

# 2b. Validar el arquetipo.
$arq = $manif.arquetipos.$Arquetipo
if (-not $arq) { Die "arquetipo desconocido: '$Arquetipo'. Opciones: $($manif.arquetipos.PSObject.Properties.Name -join ', ')" }
if (-not $arq.disponible) { Die "el arquetipo '$Arquetipo' aun no esta disponible: $($arq.nota)" }

# Piezas de motor que el arquetipo EXCLUYE (p.ej. code-first no quiere el probar-gate
# generico ni el andon.yml: su verificar code-first customizado no los pasa; jidoka#38).
# No se siembran, y se anotan en el sello 'excluir' para que -Actualizar no las re-agregue.
$excluirMotor = @()
if ($arq.excluir_motor) { $excluirMotor = @($arq.excluir_motor) }

# 3. Preparar el destino (git init si hace falta).
if (-not (Test-Path -LiteralPath $Destino)) {
  if (-not $Yes) {
    $r = Read-Host "El destino '$Destino' no existe. Crearlo? (s/N)"
    if ($r -ne 's' -and $r -ne 'S') { Die "cancelado por el usuario" }
  }
  New-Item -ItemType Directory -Path $Destino -Force | Out-Null
}
$Destino = (Resolve-Path -LiteralPath $Destino).Path
if ($Destino -eq $jidoka) { Die "el destino no puede ser el propio repo de Jidoka" }
if (-not (Test-Path (Join-Path $Destino '.git'))) {
  Info "el destino no es un repo git; corriendo 'git init'..."
  # 2>$null (no 2>&1): bajo ErrorActionPreference=Stop, 2>&1 envolveria un aviso
  # de git a stderr como ErrorRecord y abortaria el instalador. 2>$null lo descarta.
  git init -q $Destino 2>$null | Out-Null
}

# Brownfield: recuerda si .claude/settings.json YA existia antes de sembrar. Si es
# asi, el no-clobber lo preservara y puede quedar sin cablear los hooks recien
# sembrados -- se avisa mas abajo (jidoka#37).
$settingsRel = '.claude/settings.json'
$settingsDst = Join-Path $Destino $settingsRel
$settingsPreexistia = Test-Path -LiteralPath $settingsDst

# 4. Copiar el motor generico segun el manifiesto.
Info "Sembrando el motor generico..."
foreach ($e in $manif.motor) {
  if ($excluirMotor -contains $e.destino) { Info "(excluida por el arquetipo '$Arquetipo', se omite: $($e.destino))"; continue }
  $src = Join-Path $jidoka $e.origen
  $dst = Join-Path $Destino $e.destino
  if (-not (Test-Path -LiteralPath $src)) { Info "(origen ausente, se omite: $($e.origen))"; continue }
  if ($e.dir) { Copy-DirSafe $src $dst } else { Copy-Safe $src $dst }
}

# 4b. AVISO brownfield (jidoka#37): si .claude/settings.json ya existia, el no-clobber
#     lo preservo -- pero puede no cablear los Stop hooks recien sembrados ni cubrir
#     Bash en el matcher PreToolUse. No falla la instalacion: es aviso para reconciliar.
if ($settingsPreexistia) {
  $txt = Get-Content -LiteralPath $settingsDst -Raw
  $faltan = @()
  foreach ($h in @('review-stop.ps1', 'andon-stop.ps1', 'gemba-stop.ps1')) {
    if ($txt -notmatch [regex]::Escape($h)) { $faltan += $h }
  }
  # Cobertura de Bash en el PreToolUse (deteccion simple por substring del matcher).
  $bashCubierto = ($txt -match '"matcher"\s*:\s*"[^"]*Bash[^"]*"')
  if ($faltan.Count -gt 0 -or -not $bashCubierto) {
    Write-Host "  [AVISO] tu .claude/settings.json se preservo (no-clobber), pero puede dejar hooks recien sembrados sin cablear:" -ForegroundColor Yellow
    if ($faltan.Count -gt 0) { Write-Host "          - no referencia estos Stop hooks del motor: $($faltan -join ', ')" -ForegroundColor Yellow }
    if (-not $bashCubierto)  { Write-Host "          - su matcher PreToolUse no cubre 'Bash' (el hook no-memorias no corre en comandos Bash)" -ForegroundColor Yellow }
    Write-Host "          Reconcilialo contra el .claude/settings.json del motor sembrado (compara y adopta lo que falte)." -ForegroundColor Yellow
  }
}

# 5. Sembrar la ley del arquetipo -> ley_destino.
$leySrc = Join-Path $jidoka $arq.ley
$leyDst = Join-Path $Destino $manif.ley_destino
Copy-Safe $leySrc $leyDst

# 6. Crear stubs (solo si faltan).
Info "Creando stubs (solo los que falten)..."
foreach ($s in $manif.stubs) {
  $dst = Join-Path $Destino $s.ruta
  if (Test-Path -LiteralPath $dst) { Skip $dst; $script:saltados++; continue }
  $parent = Split-Path -Parent $dst
  if ($parent -and -not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
  [System.IO.File]::WriteAllText($dst, $s.contenido, $utf8)
  $script:stubs++
}

# 6b. Stubs ESPECIFICOS del arquetipo (la matriz ejecutable): la semilla del QUE
#     (grafo de notas vs brief) y la gobernanza si el arquetipo la pide.
$extra = @()
if ($arq.producto -and $manif.stubs_arquetipo.($arq.producto)) { $extra += $manif.stubs_arquetipo.($arq.producto) }
if ($arq.gobernanza -and $manif.stubs_arquetipo.gobernanza) { $extra += $manif.stubs_arquetipo.gobernanza }
foreach ($s in $extra) {
  $dst = Join-Path $Destino $s.ruta
  if (Test-Path -LiteralPath $dst) { Skip $dst; $script:saltados++; continue }
  $parent = Split-Path -Parent $dst
  if ($parent -and -not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
  [System.IO.File]::WriteAllText($dst, $s.contenido, $utf8)
  $script:stubs++
}

# 6c. Sellar la version del motor sembrado. El hijo sabe de que Jidoka viene su
#     maquinaria (version + hash de cada pieza de motor). Es la linea base para el
#     modo -Actualizar (conciencia de tres vias) y el aviso de divergencia. No-clobber:
#     si el sello ya existe (re-instalacion), no se toca -- lo actualiza -Actualizar.
$versionPath = Join-Path $jidoka 'tools/version.txt'
$version = if (Test-Path $versionPath) { (Get-Content $versionPath -Raw).Trim() } else { 'desconocida' }
$selloDst = Join-Path $Destino 'tools/jidoka-motor.json'
if (Test-Path -LiteralPath $selloDst) { Skip $selloDst; $script:saltados++ }
else {
  # CLASIFICA cada pieza (misma logica que -Sellar): compara el archivo del destino
  # contra la FUENTE de Jidoka. Pristina (recien sembrada, o ya identica) -> a la
  # semilla; customizada (brownfield preservado por no-clobber) -> OMITIDA, para que
  # un -Actualizar posterior la vea DIVERGE y la preserve (jidoka#36). Las excluidas
  # por el arquetipo se anotan en 'excluir' para que no se re-agreguen (jidoka#38).
  $clasif = Get-SelloClasificado $jidoka $manif $Destino $excluirMotor
  # Cosecha #7: el sello registra el arquetipo elegido (producto/gobernanza) para que
  # un -Actualizar futuro pueda decidir stubs condicionados a arquetipo sin adivinar.
  $sello = [ordered]@{ version = $version; sembrado_hashes = $clasif.seed }
  if ($arq.producto) { $sello.producto = $arq.producto }
  if ($arq.gobernanza) { $sello.gobernanza = $true }
  if ($excluirMotor.Count) { $sello.excluir = @($excluirMotor) }
  [System.IO.File]::WriteAllText($selloDst, (($sello | ConvertTo-Json -Depth 5) + "`n"), $utf8)
  $extra = ""
  if ($clasif.divergen.Count) { $extra = ", $($clasif.divergen.Count) customizada(s) preservada(s)" }
  if ($excluirMotor.Count) { $extra += ", $($excluirMotor.Count) excluida(s) por arquetipo" }
  Ok "sello de version: tools/jidoka-motor.json (Jidoka $version, $($clasif.seed.Count) pieza(s) de motor$extra)"
}

# 7. Encender lo manual: core.hooksPath.
if ($manif.post.hooksPath) {
  git -C $Destino config core.hooksPath $manif.post.hooksPath 2>$null | Out-Null
  if ($LASTEXITCODE -eq 0) { Ok "core.hooksPath = $($manif.post.hooksPath)" }
  else { Info "(no pude fijar core.hooksPath; hazlo a mano: git config core.hooksPath $($manif.post.hooksPath))" }
}

# 8. Resumen + siguientes pasos.
Write-Host ""
Write-Host "== Sembrado: $($script:copiados) archivo(s), $($script:stubs) stub(s); $($script:saltados) saltado(s) (no clobber). ==" -ForegroundColor Green
Write-Host "Siguientes pasos:" -ForegroundColor Cyan
$n = 1
foreach ($p in $manif.post.siguientes_pasos) { Write-Host "  $n. $p"; $n++ }
exit 0
