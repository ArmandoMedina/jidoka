#Requires -Version 5
# reporte-avance.ps1 - el REPORTE DE AVANCE SIN TERMINAL (FLU-1, R7). Una VISTA de solo
# lectura que arma un .html AUTOCONTENIDO (cero dependencias/CDN/servidor; se abre con
# doble clic, como la linterna estado-gobierno.ps1) para que el cliente se lo mande TAL
# CUAL a un tercero NO-tecnico (la autoridad del dominio de su lab, o su socio) y lo
# entienda en menos de 5 minutos -- sin traducir nada.
#
# Cinco secciones en lenguaje LLANO (cero jerga: nada de "gate"/"WIP"/"rebanada"/"PR"/
# "commit" -- se traducen a "control automatico"/"limite de trabajo abierto"/"entrega
# parcial"/"revision"/"registro"):
#   1. Que se termino      -- la seccion tope del CHANGELOG, cada punto en frase llana.
#   2. En que vamos        -- el sprint activo con un HILL CHART (Basecamp: subir la loma =
#                             aun resolviendo lo desconocido; bajar = ejecutando lo conocido;
#                             NUNCA porcentajes). SVG inline ESTATICO, sin JS.
#   3. Que espera una respuesta -- esperando_terceros agrupado por quien.
#   4. Que se descarto     -- la ultima entrada de docs/MUERTOS.md, o "Nada se ha descartado".
#   5. Que sigue           -- los 3 siguientes con su tamano en llano.
#
# Fuentes (todas ya existen; DEGRADA con gracia si falta alguna, no truena):
#   - tools/estado-flujo.ps1 -Json  -> siguientes, esperando_terceros, sprint_activo,
#     conteos (se ELIGE reusar este motor ya probado en vez de re-parsear ROADMAP/flujo a
#     mano: es lo mas simple y su parseo ya tiene self-test en probar-flujo.ps1). Se invoca
#     el hermano de tools/ (por $PSScriptRoot) con -Repo, aunque el repo objetivo no lo
#     tenga sembrado -- igual que probar-flujo invoca el verificar real contra un fixture.
#   - CHANGELOG.md (seccion tope)   -> seccion 1.
#   - HANDOFF.md (linea "El QUE aprobado" + seccion "Avance") -> el hill (seccion 2).
#   - docs/MUERTOS.md (ultima entrada) -> seccion 4.
#
# HEURISTICA DEL HILL (documentada aqui, sin porcentajes -- filosofia Basecamp):
#   * Los TEMAS de cada movimiento salen de la frase llana ya escrita en HANDOFF ("El QUE
#     aprobado ... -- los documentos ... dejan de crecer solos, el trabajo entra con limite,
#     y el avance ... sin terminal"): 3 clausulas = M1/M2/M3 en lenguaje llano, del propio
#     doc (nadie las redacta aqui).
#   * El ESTADO de cada movimiento se lee de los marcadores de la seccion "Avance": un
#     movimiento con [check] esta HECHO; con [cuadro blanco] esta EN CURSO.
#   * La POSICION en la loma:
#       - HECHO      -> ya bajo la loma del todo: cerca del pie derecho (t en [0.80, 0.96]).
#       - EN CURSO y con el DISENO YA FIJADO (la seccion Avance dice "fijado")
#                    -> BAJANDO la loma: solo falta ejecutar lo conocido (t ~ 0.62).
#       - EN CURSO y con incognitas de diseno todavia
#                    -> SUBIENDO la loma: aun antes de la cima (t ~ 0.33).
#     (t: 0 = pie izquierdo/arranque, 0.5 = cima, 1 = pie derecho/terminado; altura = seno.)
#
# El .ps1 es ASCII a proposito (PS 5.1, sin depender del BOM). Los acentos y comillas del
# texto ESTATICO se escriben como entidades HTML (ASCII en la fuente) y se decodifican a
# UTF-8 real al final (Decode-Accents, que usa [char]); el texto DINAMICO ya trae acentos
# reales leidos de los .md. El HTML de salida se escribe UTF-8 SIN BOM.
#
#   -Repo <ruta>    repo a reportar (default: el padre de tools/, o sea este repo)
#   -Salida <ruta>  a donde escribir el .html (default: <repo>/.jidoka/reporte-avance.html;
#                   .jidoka/ esta gitignoreado, como los demos de la linterna)

param([string]$Repo = '', [string]$Salida = '')

$ErrorActionPreference = 'Continue'
$repoRoot = if ($Repo) { $Repo } else { Split-Path -Parent $PSScriptRoot }
if (-not $Salida) { $Salida = Join-Path $repoRoot '.jidoka/reporte-avance.html' }

# Acentos reales para las cadenas que se arman por codigo (esta fuente es ASCII).
$acA = [char]0x00E1; $acE = [char]0x00E9; $acI = [char]0x00ED; $acO = [char]0x00F3; $acU = [char]0x00FA; $acN = [char]0x00F1
$EM  = [char]0x2014   # em dash
$EN  = [char]0x2013   # en dash
$MID = [char]0x00B7   # middot
$CHK = [char]0x2705   # marcador HECHO
$WHT = [char]0x2B1C   # marcador EN CURSO

# --------------------------------------------------------------------------- helpers
function Read-Lines($p) {
  if (Test-Path -LiteralPath $p) { return @([System.IO.File]::ReadAllLines($p)) }
  return @()
}
function Esc([string]$s) {
  if ($null -eq $s) { return '' }
  return ($s -replace '&', '&amp;' -replace '<', '&lt;' -replace '>', '&gt;')
}
function Cap([string]$s) {
  if (-not $s) { return $s }
  if ($s.Length -eq 1) { return $s.ToUpper() }
  return $s.Substring(0, 1).ToUpper() + $s.Substring(1)
}
function EnsureDot([string]$s) {
  if (-not $s) { return $s }
  $s = $s.TrimEnd()
  if ($s -notmatch '[.!?]$') { $s = $s + '.' }
  return $s
}

# La traduccion de jerga a lenguaje llano. Es el corazon del "sin traducir nada": ni una
# palabra tecnica llega al tercero. Se aplica a TODO texto dinamico. Frases multi-palabra
# primero, luego palabras sueltas con frontera (\b) para no morder subcadenas.
function Scrub-Jerga([string]$s) {
  if (-not $s) { return $s }
  $r = $s
  $r = $r -replace ('(?i)l' + $acI + 'mite WIP'), ('l' + $acI + 'mite de trabajo abierto')
  $r = $r -replace '(?i)\bStop hooks?\b', 'automatismos que frenan'
  $r = $r -replace '(?i)\bgates\b', ('controles autom' + $acA + 'ticos')
  $r = $r -replace '(?i)\bgate\b', ('control autom' + $acA + 'tico')
  $r = $r -replace '(?i)\bWIP\b', 'trabajo abierto'
  $r = $r -replace '(?i)\bcommits\b', 'registros'
  $r = $r -replace '(?i)\bcommit\b', 'registro'
  $r = $r -replace '(?i)\brebanadas\b', 'entregas parciales'
  $r = $r -replace '(?i)\brebanada\b', 'entrega parcial'
  $r = $r -replace '(?i)\bpushes\b', 'publicaciones'
  $r = $r -replace '(?i)\bpush\b', ('publicaci' + $acO + 'n')
  $r = $r -replace '(?i)\bPRs\b', 'revisiones'
  $r = $r -replace '(?i)\bPR\b', ('revisi' + $acO + 'n')
  $r = $r -replace '(?i)\bGembas\b', 'revisiones con el cliente'
  $r = $r -replace '(?i)\bGemba\b', ('revisi' + $acO + 'n con el cliente')
  $r = $r -replace '(?i)\bhooks\b', 'automatismos'
  $r = $r -replace '(?i)\bhook\b', 'automatismo'
  $r = $r -replace '(?i)\bHANDOFF\b', 'documento de relevo'
  $r = $r -replace '(?i)\bROADMAP\b', 'plan de trabajo'
  $r = $r -replace '(?i)\bCHANGELOG\b', 'registro de cambios'
  $r = $r -replace '(?i)\bbacklog\b', 'lista de pendientes'
  $r = $r -replace '(?i)\bSessionStart\b', ('al abrir la sesi' + $acO + 'n')
  $r = $r -replace '(?i)\bfixtures\b', 'casos de prueba'
  $r = $r -replace '(?i)\bself-tests?\b', 'auto-pruebas'
  # colapsa espacios que puedan quedar de reemplazos vacios
  $r = ($r -replace '\s+', ' ').Trim()
  return $r
}

# Limpia un bullet del CHANGELOG a una frase llana: quita el tipo (feat/fix/...), los
# backticks y su contenido (paths/codigo), los nombres de archivo, parentesis/corchetes,
# negritas/cursivas, y traduce la jerga. $full = usar la linea entera (no solo el titulo
# antes del primer ':').
function To-Llano([string]$raw, [bool]$full = $false) {
  $t = $raw
  $t = $t -replace '^\s*-\s*', ''
  $t = $t -replace '`[^`]*`', ''            # quita spans de codigo (tipos, paths)
  $t = $t -replace '\*\*', ''               # negritas
  $t = $t -replace '\*([^*]*)\*', '$1'      # cursivas (conserva el interior)
  # cabeza de tipo suelta al inicio (ADR NNNN, o un tipo sin backticks) + guion
  $t = $t -replace '(?i)^\s*ADR\s+\d+\s*', ''
  $t = $t -replace '(?i)^\s*(feat|fix|test|docs|chore|breaking)\s*', ''
  $t = $t.TrimStart(' ', '-', $EM, $EN, $MID)
  # Los parentesis/corchetes se quitan ANTES de cortar por ':' -- si no, un ':' DENTRO de un
  # parentesis ("(R6, gestion visual: el estado se ve)") cortaria a media frase y dejaria el
  # parentesis sin cerrar ("(R6, gestion visual"). Fuera primero, luego el corte por titulo.
  $t = $t -replace '\([^)]*\)', ''          # parentesis
  $t = $t -replace '\[[^\]]*\]', ''         # corchetes
  if (-not $full) {
    $ci = $t.IndexOf(':')
    if ($ci -ge 15) { $t = $t.Substring(0, $ci) }
  }
  $t = $t -replace '\b[\w-]+\.(md|ps1|json|html|yml|txt|js|vsix)\b', ''  # nombres de archivo
  $t = $t.TrimStart(' ', '-', $EM, $EN, $MID, ':')
  $t = ($t -replace '\s+', ' ').Trim()
  $t = Scrub-Jerga $t
  if ($t.Length -gt 155) { $t = $t.Substring(0, 152).TrimEnd() + '...' }
  return $t
}

function Apetito-Llano([string]$a) {
  if (-not $a) { return '' }
  if ($a -match '(\d+)\s*h') {
    $n = $matches[1]
    $pl = if ([int]$n -eq 1) { 'hora' } else { 'horas' }
    return '~' + $n + ' ' + $pl + ' de trabajo'
  }
  return $a
}

function Quien-Heading([string]$q) {
  switch -Regex ($q) {
    '^cliente$'    { return ('A la espera de una decisi' + $acO + 'n del cliente') }
    'cuenta-npm'   { return ('A la espera de que el cliente habilite su cuenta de publicaci' + $acO + 'n') }
    'ventana-labs' { return 'A la espera de una ventana de tiempo en los laboratorios' }
    'no-windows'   { return 'A la espera de poder probar fuera de Windows' }
    default        { return ('A la espera de ' + ($q -replace '-', ' ')) }
  }
}

# --------------------------------------------------------------------- fuente: la vista
# Se reusa el motor estado-flujo.ps1 -Json (ya probado): siguientes, esperando_terceros,
# sprint_activo, conteos, muertos_recientes. Se invoca el hermano de tools/ con -Repo.
# estado-flujo emite su JSON en UTF-8 (fija [Console]::OutputEncoding a UTF-8 al arrancar);
# hay que DECODIFICAR su stdout como UTF-8 aqui tambien, o los acentos/guiones largos llegan
# como mojibake (los titulos de esperando_terceros/siguientes salen "P&aacute;rrafo" -> basura).
$vista = $null
$estadoScript = Join-Path $PSScriptRoot 'estado-flujo.ps1'
if (Test-Path -LiteralPath $estadoScript) {
  $prevOut = [Console]::OutputEncoding
  try {
    try { [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false) } catch {}
    $raw = & powershell -NoProfile -ExecutionPolicy Bypass -File $estadoScript -Json -Repo $repoRoot 2>$null | Out-String
    if ($LASTEXITCODE -eq 0 -and $raw.Trim()) { $vista = $raw | ConvertFrom-Json }
  } catch { $vista = $null }
  finally { try { [Console]::OutputEncoding = $prevOut } catch {} }
}
$sprintActivo = ''
if ($vista -and $vista.sprint_activo) { $sprintActivo = [string]$vista.sprint_activo }

# --------------------------------------------------------- fuente: CHANGELOG (seccion 1)
$clLines = Read-Lines (Join-Path $repoRoot 'CHANGELOG.md')
$clSubtitle = ''
$clBullets = @()
$inTop = $false
foreach ($ln in $clLines) {
  if ($ln -match '^##\s+\[') {
    if ($inTop) { break }   # llego la segunda version: fin de la seccion tope
    $inTop = $true
    continue
  }
  if (-not $inTop) { continue }
  if (-not $clSubtitle -and $ln -match '^###\s+(.+)$') {
    $clSubtitle = ($matches[1] -replace '\([^)]*\)\s*$', '').Trim()
    continue
  }
  if ($ln -match '^-\s+\S') { $clBullets += $ln }
}
$sec1Items = @()
foreach ($b in ($clBullets | Select-Object -First 12)) {
  $type = ''
  if ($b -match '(?i)^\s*-\s*\*\*\s*`?(feat|fix|test|docs|chore|breaking)`?') { $type = $matches[1].ToLower() }
  elseif ($b -match '(?i)^\s*-\s*\*\*\s*ADR\s+\d+') { $type = 'adr' }
  $p = To-Llano $b $false
  if ($type -eq 'test' -and $p.Length -lt 12) { $p = 'nuevas pruebas autom' + $acA + 'ticas que blindan lo anterior' }
  elseif ($p.Length -lt 12) { $p = To-Llano $b $true }
  switch ($type) {
    'fix' { $p = ('se corrigi' + $acO + ' un problema: ' + $p) }
    'adr' { $p = ('decisi' + $acO + 'n registrada: ' + $p) }
    'test' { $p = ('pruebas: ' + $p) }
  }
  $p = EnsureDot (Cap $p)
  if ($p) { $sec1Items += $p }
}

# --------------------------------------------------------- fuente: HANDOFF (el hill, sec 2)
$hoLines = Read-Lines (Join-Path $repoRoot 'HANDOFF.md')
# (a) los TEMAS llanos de los movimientos, de la frase "El QUE aprobado ... -- <clausulas>".
$temas = @()
foreach ($ln in $hoLines) {
  if ($ln -match 'aprobado por el cliente') {
    $frase = $ln
    # el PRIMER em dash abre las clausulas del QUE ("... a la Casa -- los documentos dejan de
    # crecer, el trabajo entra con limite, y el avance se ve sin terminal"): son los 3 temas.
    # (LastIndexOf agarraria el em dash del Plan-contrato "-- 9 rebanadas...", que NO son temas.)
    $li = $frase.IndexOf($EM)
    if ($li -lt 0) { $li = $frase.IndexOf(' - ') }
    if ($li -ge 0) {
      $cola = $frase.Substring($li + 1)
      # corta en el primer punto seguido (antes de "Plan-contrato: ...")
      $cola = ($cola -split '\. ')[0]
      $parts = $cola -split ','
      foreach ($pp in $parts) {
        $c = $pp.Trim()
        $c = $c -replace '^(y|e)\s+', ''
        $c = $c.TrimEnd('.').Trim()
        if ($c.Length -ge 6) { $temas += (Scrub-Jerga $c) }
      }
    }
    break
  }
}
# (b) el ESTADO de cada movimiento, de los marcadores de la seccion "Avance".
$avanceTxt = ''
$movs = @()   # orden de aparicion: [pscustomobject]{ id; done }
$patMark = '(' + $CHK + '|' + $WHT + ')\s*\**\s*(R0|M[0-9])'
foreach ($ln in $hoLines) {
  foreach ($m in [regex]::Matches($ln, $patMark)) {
    $id = $m.Groups[2].Value
    if ($id -eq 'R0') { continue }   # R0 es el arranque (plan), no un movimiento de la loma
    if (@($movs | Where-Object { $_.id -eq $id }).Count -gt 0) { continue }
    $done = ($m.Groups[1].Value -eq $CHK)
    $movs += [pscustomobject]@{ id = $id; done = $done }
  }
  if ($ln -match ('(?i)(' + $CHK + '|' + $WHT + '|Avance|fijado|Dise' + $acN + 'o)')) { $avanceTxt += ' ' + $ln }
}
$disenoFijado = ($avanceTxt -match '(?i)fijad')
# ordena por numero de movimiento
$movs = @($movs | Sort-Object { [int]($_.id -replace '\D', '') })

# arma los puntos del hill: tema (por indice) + estado + posicion t (ver HEURISTICA arriba).
$done = @($movs | Where-Object { $_.done })
$pend = @($movs | Where-Object { -not $_.done })
function Spread($n, $lo, $hi) {
  if ($n -le 0) { return @() }
  if ($n -eq 1) { return @((($lo + $hi) / 2)) }
  $out = @(); for ($i = 0; $i -lt $n; $i++) { $out += ($lo + $i * (($hi - $lo) / ($n - 1))) }
  return $out
}
$tDone = Spread $done.Count 0.80 0.96
$tPend = if ($disenoFijado) { Spread $pend.Count 0.56 0.70 } else { Spread $pend.Count 0.24 0.42 }
$puntos = @()
$di = 0; $pi = 0
foreach ($mv in $movs) {
  $num = [int]($mv.id -replace '\D', '')
  $tema = if ($num -ge 1 -and $num -le $temas.Count) { $temas[$num - 1] } else { 'Movimiento ' + $num + ' del ciclo de trabajo' }
  if ($mv.done) { $t = $tDone[$di]; $di++ } else { $t = $tPend[$pi]; $pi++ }
  $puntos += [pscustomobject]@{ num = $num; tema = (Cap $tema); done = $mv.done; t = $t }
}

# --------------------------------------------------------- fuente: MUERTOS (seccion 4)
$muertosRel = 'docs/MUERTOS.md'
$flujoPath = Join-Path $repoRoot 'tools/flujo.json'
if (Test-Path -LiteralPath $flujoPath) {
  try { $fj = Get-Content -LiteralPath $flujoPath -Raw | ConvertFrom-Json; if ($fj.roadmap -and $fj.roadmap.muertos) { $muertosRel = [string]$fj.roadmap.muertos } } catch {}
}
$muLines = Read-Lines (Join-Path $repoRoot $muertosRel)
$muFecha = ''
$muItems = @()   # { titulo; motivo }
$lastIdx = -1
for ($i = 0; $i -lt $muLines.Count; $i++) { if ($muLines[$i] -match '^##\s+(\S+)') { $lastIdx = $i; $muFecha = $matches[1] } }
if ($lastIdx -ge 0) {
  $curTit = $null
  for ($i = $lastIdx + 1; $i -lt $muLines.Count; $i++) {
    $ln = $muLines[$i]
    if ($ln -match '^##\s+') { break }
    if ($ln -match '^-\s+\S') {
      $tit = $ln
      if ($ln -match '\*\*(.+?)\*\*') { $tit = $matches[1].Trim() } else { $tit = ($ln -replace '^\s*-\s*', '').Trim() }
      $tit = Scrub-Jerga (To-Llano $ln $true)
      $curTit = [pscustomobject]@{ titulo = $tit; motivo = '' }
      $muItems += $curTit
    }
    elseif ($ln -match '^\s+-\s+(.+)$' -and $curTit) {
      $curTit.motivo = Scrub-Jerga ($matches[1].Trim())
    }
  }
}

# =========================================================================== construir HTML
# Cada valor dinamico: Scrub-Jerga (ya aplicado arriba) -> H() (escape) -> insertar. El
# texto estatico va con entidades HTML y se decodifica al final (Decode-Accents).

# --- seccion 1
$s1 = New-Object System.Text.StringBuilder
[void]$s1.Append('<section><h2>Qu&eacute; se termin&oacute;</h2>')
if ($clSubtitle) { [void]$s1.Append('<p class="lead">Lo m&aacute;s reciente que qued&oacute; listo: <em>' + (Esc (Scrub-Jerga $clSubtitle)) + '</em></p>') }
if ($sec1Items.Count -gt 0) {
  [void]$s1.Append('<ul>')
  foreach ($it in $sec1Items) { [void]$s1.Append('<li>' + (Esc $it) + '</li>') }
  [void]$s1.Append('</ul>')
} else {
  [void]$s1.Append('<p class="empty">A&uacute;n no hay entregas registradas.</p>')
}
[void]$s1.Append('</section>')

# --- seccion 2 (hill)
$sprintNom = ''
if ($sprintActivo) {
  $sprintNom = ($sprintActivo -replace '\s*\(.*$', '').Trim()
  $sprintNom = (Cap ($sprintNom -replace '-', ' '))
}
$s2 = New-Object System.Text.StringBuilder
[void]$s2.Append('<section><h2>En qu&eacute; vamos</h2>')
$intro2 = 'La loma cuenta el avance <strong>sin porcentajes</strong>: subir la loma es descubrir lo que a&uacute;n no sabemos; bajar es ejecutar lo que ya est&aacute; claro. Un punto arriba todav&iacute;a tiene dudas por resolver; uno bajando ya solo es cuesti&oacute;n de hacerlo.'
if ($sprintNom) { [void]$s2.Append('<p class="lead">Trabajo en curso: <strong>' + (Esc $sprintNom) + '</strong>. ' + $intro2 + '</p>') }
else { [void]$s2.Append('<p class="lead">' + $intro2 + '</p>') }

# --- SVG del hill (estatico) ---
$base = 248.0; $peak = 168.0; $x0 = 48.0; $wid = 624.0
$pts = for ($i = 0; $i -le 48; $i++) { $t = $i / 48.0; $x = $x0 + $t * $wid; $y = $base - [math]::Sin($t * [math]::PI) * $peak; ('{0:0.0},{1:0.0}' -f $x, $y) }
$poly = ($pts -join ' ')
$crestX = $x0 + 0.5 * $wid
$svg = New-Object System.Text.StringBuilder
[void]$svg.Append('<svg class="hill" viewBox="0 0 720 300" role="img" aria-label="Loma de avance del ciclo de trabajo" preserveAspectRatio="xMidYMid meet">')
[void]$svg.Append('<line x1="' + ('{0:0.0}' -f $x0) + '" y1="248" x2="' + ('{0:0.0}' -f ($x0 + $wid)) + '" y2="248" class="hbase"/>')
[void]$svg.Append('<line x1="' + ('{0:0.0}' -f $crestX) + '" y1="80" x2="' + ('{0:0.0}' -f $crestX) + '" y2="248" class="hcrest"/>')
[void]$svg.Append('<polyline points="' + $poly + '" class="hline"/>')
[void]$svg.Append('<text x="' + ('{0:0.0}' -f $crestX) + '" y="72" class="hcap ct">cima</text>')
[void]$svg.Append('<text x="150" y="276" class="hcap cl">Subiendo: a&uacute;n resolviendo dudas</text>')
[void]$svg.Append('<text x="560" y="276" class="hcap cr">Bajando: ya solo ejecutando</text>')
foreach ($p in $puntos) {
  $x = $x0 + $p.t * $wid; $y = $base - [math]::Sin($p.t * [math]::PI) * $peak
  $cls = if ($p.done) { 'hdone' } else { 'hcurso' }
  [void]$svg.Append('<circle cx="' + ('{0:0.0}' -f $x) + '" cy="' + ('{0:0.0}' -f $y) + '" r="12" class="' + $cls + '"/>')
  [void]$svg.Append('<text x="' + ('{0:0.0}' -f $x) + '" y="' + ('{0:0.0}' -f ($y + 4)) + '" class="hnum">' + $p.num + '</text>')
}
[void]$svg.Append('</svg>')
[void]$s2.Append([string]$svg)

if ($puntos.Count -gt 0) {
  [void]$s2.Append('<ol class="hlegend">')
  foreach ($p in $puntos) {
    $estado = if ($p.done) { 'hecho' } else { 'en curso' }
    $dotcls = if ($p.done) { 'ddone' } else { 'dcurso' }
    [void]$s2.Append('<li><span class="badge ' + $dotcls + '">' + $p.num + '</span> ' + (Esc (EnsureDot $p.tema)).TrimEnd('.') + ' ' + $EM + ' <strong class="' + $dotcls + '-t">' + $estado + '</strong></li>')
  }
  [void]$s2.Append('</ol>')
} else {
  [void]$s2.Append('<p class="empty">A&uacute;n no hay movimientos del ciclo de trabajo que mostrar.</p>')
}
[void]$s2.Append('</section>')

# --- seccion 3
$s3 = New-Object System.Text.StringBuilder
[void]$s3.Append('<section><h2>Qu&eacute; espera una respuesta</h2>')
$esperando = @()
if ($vista -and $vista.esperando_terceros) { $esperando = @($vista.esperando_terceros) }
if ($esperando.Count -gt 0) {
  foreach ($grp in ($esperando | Group-Object quien)) {
    [void]$s3.Append('<div class="wgroup"><p class="wtitle">' + (Esc (Quien-Heading $grp.Name)) + ':</p><ul>')
    foreach ($it in $grp.Group) {
      $ttl = Scrub-Jerga (To-Llano ('- **' + $it.titulo + '**') $true)
      [void]$s3.Append('<li>' + (Esc $ttl) + '</li>')
    }
    [void]$s3.Append('</ul></div>')
  }
} else {
  [void]$s3.Append('<p class="empty">Ahora mismo nada espera respuesta de terceros.</p>')
}
[void]$s3.Append('</section>')

# --- seccion 4
$s4 = New-Object System.Text.StringBuilder
[void]$s4.Append('<section><h2>Qu&eacute; se descart&oacute;</h2>')
if ($muItems.Count -gt 0) {
  [void]$s4.Append('<p class="lead">Lo m&aacute;s reciente que se dej&oacute; ir')
  if ($muFecha) { [void]$s4.Append(' (' + (Esc $muFecha) + ')') }
  [void]$s4.Append(':</p><ul>')
  foreach ($it in $muItems) {
    $li = '<li><strong>' + (Esc (EnsureDot $it.titulo)).TrimEnd('.') + '</strong>'
    if ($it.motivo) { $li += ' ' + $EM + ' ' + (Esc $it.motivo) }
    $li += '</li>'
    [void]$s4.Append($li)
  }
  [void]$s4.Append('</ul>')
} else {
  [void]$s4.Append('<p class="empty">Nada se ha descartado a&uacute;n.</p>')
}
[void]$s4.Append('</section>')

# --- seccion 5
$s5 = New-Object System.Text.StringBuilder
[void]$s5.Append('<section><h2>Qu&eacute; sigue</h2>')
$siguientes = @()
if ($vista -and $vista.siguientes) { $siguientes = @($vista.siguientes) }
if ($siguientes.Count -gt 0) {
  [void]$s5.Append('<ul class="next">')
  foreach ($sg in $siguientes) {
    $ttl = Scrub-Jerga (To-Llano ('- **' + $sg.titulo + '**') $true)
    $li = '<li><span class="ntitle">' + (Esc (EnsureDot $ttl)).TrimEnd('.') + '</span>'
    $tam = Apetito-Llano ([string]$sg.apetito)
    if ($tam) { $li += ' <span class="nsize">' + (Esc $tam) + '</span>' }
    if ($sg.PSObject.Properties['vence'] -and $sg.vence) { $li += ' <span class="nsize">fecha l&iacute;mite: ' + (Esc ([string]$sg.vence)) + '</span>' }
    $li += '</li>'
    [void]$s5.Append($li)
  }
  [void]$s5.Append('</ul>')
} else {
  [void]$s5.Append('<p class="empty">No hay nada m&aacute;s en la cola por ahora.</p>')
}
[void]$s5.Append('</section>')

# --- fecha
$meses = @('enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre')
$now = Get-Date
$fechaLarga = ('' + $now.Day + ' de ' + $meses[$now.Month - 1] + ' de ' + $now.Year)
$subtitleHead = if ($sprintNom) { 'C&oacute;mo va: ' + (Esc $sprintNom) } else { 'El estado del proyecto, en claro' }

$sec1 = [string]$s1; $sec2 = [string]$s2; $sec3 = [string]$s3; $sec4 = [string]$s4; $sec5 = [string]$s5

$html = @"
<!doctype html>
<html lang="es"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Reporte de avance</title>
<style>
  :root{
    --bg:#ffffff;--fg:#1c2128;--mut:#5b6472;--card:#f6f7f9;--line:#e4e8ee;
    --accent:#2f6fed;--done:#1f9d63;--curso:#c9791a;--on-dot:#ffffff;--soft:#eef1f6;
  }
  @media (prefers-color-scheme:dark){
    :root{
      --bg:#0f1115;--fg:#e6e8ee;--mut:#9aa3b2;--card:#171a21;--line:#2a2f3a;
      --accent:#6ea0ff;--done:#31c48d;--curso:#f5b942;--on-dot:#0f1115;--soft:#1c212b;
    }
  }
  *{box-sizing:border-box}
  html,body{margin:0}
  body{background:var(--bg);color:var(--fg);
    font:16px/1.65 system-ui,-apple-system,Segoe UI,Roboto,Helvetica,Arial,sans-serif;
    -webkit-text-size-adjust:100%;}
  .wrap{max-width:760px;margin:0 auto;padding:28px 18px 72px;}
  header{border-bottom:2px solid var(--line);padding-bottom:16px;margin-bottom:8px;}
  h1{font-size:26px;line-height:1.2;margin:0 0 4px;font-weight:700;}
  header .sub{color:var(--fg);font-weight:600;margin:2px 0;}
  header .asof{color:var(--mut);font-size:14px;margin:2px 0 0;}
  section{padding:22px 0;border-bottom:1px solid var(--line);}
  section:last-of-type{border-bottom:0;}
  h2{font-size:20px;margin:0 0 12px;font-weight:700;}
  h2::before{content:"";display:inline-block;width:10px;height:10px;border-radius:3px;
    background:var(--accent);margin-right:9px;vertical-align:middle;}
  p{margin:0 0 12px;} p:last-child{margin-bottom:0;}
  .lead{color:var(--mut);}
  ul,ol{margin:0;padding-left:22px;} li{margin:7px 0;}
  .empty{color:var(--mut);font-style:italic;}
  em{color:var(--fg);font-style:normal;font-weight:600;}
  /* seccion 3 */
  .wgroup{margin:0 0 14px;} .wtitle{font-weight:600;margin:0 0 4px;}
  .wgroup ul{padding-left:20px;} .wgroup li{color:var(--mut);}
  /* seccion 5 */
  .next{list-style:none;padding-left:0;}
  .next li{background:var(--card);border:1px solid var(--line);border-radius:10px;
    padding:12px 14px;margin:9px 0;}
  .ntitle{font-weight:600;}
  .nsize{display:inline-block;margin-left:8px;font-size:13px;color:var(--mut);
    background:var(--soft);border-radius:20px;padding:2px 10px;white-space:nowrap;}
  /* el hill */
  .hill{width:100%;height:auto;display:block;margin:6px 0 4px;
    background:var(--card);border:1px solid var(--line);border-radius:12px;}
  .hbase{stroke:var(--line);stroke-width:1.5;}
  .hcrest{stroke:var(--line);stroke-width:1.2;stroke-dasharray:4 4;}
  .hline{fill:none;stroke:var(--accent);stroke-width:3;stroke-linecap:round;stroke-linejoin:round;}
  .hcap{fill:var(--mut);font:600 12px system-ui,sans-serif;}
  .ct{text-anchor:middle;} .cl{text-anchor:middle;} .cr{text-anchor:middle;}
  .hdone{fill:var(--done);stroke:var(--bg);stroke-width:2;}
  .hcurso{fill:var(--curso);stroke:var(--bg);stroke-width:2;}
  .hnum{fill:var(--on-dot);font:700 13px system-ui,sans-serif;text-anchor:middle;}
  .hlegend{list-style:none;padding-left:0;margin:12px 0 0;}
  .hlegend li{display:flex;align-items:baseline;gap:9px;margin:8px 0;}
  .badge{flex:0 0 auto;display:inline-flex;align-items:center;justify-content:center;
    width:22px;height:22px;border-radius:50%;color:var(--on-dot);font-weight:700;font-size:13px;}
  .ddone{background:var(--done);} .dcurso{background:var(--curso);}
  .ddone-t{color:var(--done);} .dcurso-t{color:var(--curso);}
  footer{margin-top:26px;color:var(--mut);font-size:13px;line-height:1.5;}
  footer p{margin:3px 0;}
</style></head>
<body>
<div class="wrap">
<header>
  <h1>Reporte de avance</h1>
  <p class="sub">$subtitleHead</p>
  <p class="asof">Al $fechaLarga</p>
</header>
$sec1
$sec2
$sec3
$sec4
$sec5
<footer>
  <p>Generado el $fechaLarga.</p>
  <p>Generado autom&aacute;ticamente del estado real del proyecto &mdash; nadie lo redact&oacute; a mano.</p>
</footer>
</div>
</body></html>
"@

# Decodifica las entidades de acento del texto ESTATICO a UTF-8 real (usa [char]). El
# texto dinamico ya trae acentos reales; sus escapes &amp;/&lt;/&gt; NO estan en el mapa,
# asi que quedan intactos.
function Decode-Accents([string]$s) {
  # Pares entidad->char en un ARRAY (no hashtable: las claves de hash en PS son
  # case-insensitive y '&aacute;'/'&Aacute;' colisionarian). String.Replace es
  # case-sensitive, asi que minusculas y mayusculas se distinguen bien.
  $pairs = @(
    @('&aacute;', [char]0x00E1), @('&eacute;', [char]0x00E9), @('&iacute;', [char]0x00ED), @('&oacute;', [char]0x00F3), @('&uacute;', [char]0x00FA),
    @('&Aacute;', [char]0x00C1), @('&Eacute;', [char]0x00C9), @('&Iacute;', [char]0x00CD), @('&Oacute;', [char]0x00D3), @('&Uacute;', [char]0x00DA),
    @('&ntilde;', [char]0x00F1), @('&Ntilde;', [char]0x00D1), @('&uuml;', [char]0x00FC),
    @('&laquo;', [char]0x00AB), @('&raquo;', [char]0x00BB), @('&mdash;', [char]0x2014), @('&ndash;', [char]0x2013), @('&middot;', [char]0x00B7),
    @('&iquest;', [char]0x00BF), @('&iexcl;', [char]0x00A1), @('&hellip;', [char]0x2026)
  )
  foreach ($pr in $pairs) { $s = $s.Replace([string]$pr[0], [string]$pr[1]) }
  return $s
}
$html = Decode-Accents $html

# ------------------------------------------------------------------------------- escribir
$outDir = Split-Path -Parent $Salida
if ($outDir -and -not (Test-Path -LiteralPath $outDir)) { New-Item -ItemType Directory -Path $outDir -Force | Out-Null }
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($Salida, $html, $utf8NoBom)

Write-Host ("[OK] Reporte de avance generado: {0}" -f $Salida) -ForegroundColor Green
Write-Host ("     5 secciones en lenguaje llano + hill chart del sprint. Abrelo con doble clic.")
exit 0
