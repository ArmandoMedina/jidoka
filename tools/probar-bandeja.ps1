#Requires -Version 5
# probar-bandeja.ps1 - Self-test de bandeja.ps1 (la cola "pendiente de parametrizar").
# Molde: probar-docs.ps1 -- Parte A monta un fixture git temporal y corre el script en
# proceso aparte comparando salida+exit; Parte B corre contra el repo real. ASCII, PS 5.1.

$raiz = Split-Path -Parent $PSScriptRoot
$script:pass = 0; $script:fail = 0
function Ok($m) { Write-Host "  [OK]   $m" -ForegroundColor Green; $script:pass++ }
function No($m) { Write-Host "  [FALLA] $m" -ForegroundColor Red; $script:fail++ }

Write-Host "== Probar bandeja.ps1 =="

$bandeja = Join-Path $PSScriptRoot 'bandeja.ps1'
if (-not (Test-Path $bandeja)) { No "no existe tools/bandeja.ps1"; Write-Host "== INCOMPLETO =="; exit 1 }

function Escribe($base, $rel, $contenido, $enc) {
  $abs = Join-Path $base $rel
  $dir = Split-Path -Parent $abs
  if ($dir -and -not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
  Set-Content -LiteralPath $abs -Value $contenido -Encoding $enc
}

# ------------------------------------------------------------------ Parte A (fixture git)
$fix = Join-Path ([System.IO.Path]::GetTempPath()) ("bandeja-" + [System.Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $fix -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $fix 'tools') -Force | Out-Null
Copy-Item $bandeja (Join-Path $fix 'tools/bandeja.ps1')
& git init -q $fix 2>$null | Out-Null

# ley minima: un area que cubre tools/* (con un excluye), y una que cubre docs/guias/*.
$ley = @'
[
  { "nombre": "barreras", "fuente": ["tools/*"], "excluye": ["tools/instalar.ps1"] },
  { "nombre": "guias", "fuente": ["docs/guias/*"] }
]
'@
Escribe $fix 'tools/blast-radius.json' $ley 'ASCII'

# ledger capa-2: MIDOC.md exige Alpha y Beta; el doc solo trae Alpha -> DESVIADO.
$ledger = @'
{ "capa2": [
  { "doc": "MIDOC.md",   "molde": "m.md", "requeridas": ["Alpha", "Beta"], "estricto": false },
  { "doc": "CONFDOC.md", "molde": "m.md", "requeridas": ["Alpha", "Beta"], "estricto": false }
], "capa3": [] }
'@
Escribe $fix 'tools/docs-gobernados.json' $ledger 'ASCII'

# contratos.json: con-contrato parametrizado (fuera), aceptado con firma (fuera con badge).
$ctr = @'
{ "contratos": [
  { "path": "docs/analisis/con-contrato.md", "regimen": "libre", "estado": "parametrizado" },
  { "path": "docs/analisis/aceptado.md", "regimen": "libre", "estado": "aceptado", "firma": { "quien": "Fulano" } }
] }
'@
Escribe $fix 'tools/contratos.json' $ctr 'ASCII'

# archivos de prueba
Escribe $fix 'suelto.txt' "soy un archivo suelto en la raiz sin regla" 'ASCII'              # -> HUERFANO
Escribe $fix 'docs/analisis/nota.md' "# nota`nsin regla, solo existe" 'UTF8'                # -> SOLO EXISTE
Escribe $fix 'MIDOC.md' "# t`n## Alpha`nfalta beta" 'UTF8'                                  # -> DESVIADO
Escribe $fix 'CONFDOC.md' "# t`n## Alpha`ncuerpo`n## Beta`nmas" 'UTF8'                       # -> CONFORME (fuera de la cola)
Escribe $fix 'docs/analisis/con-contrato.md' "# c`nya parametrizado" 'UTF8'                 # -> fuera (contrato)
Escribe $fix 'docs/analisis/aceptado.md' "# a`ndesviacion aceptada" 'UTF8'                  # -> fuera con badge
Escribe $fix 'tools/algo.ps1' "# cubierto por area barreras" 'ASCII'                        # -> fuera (area)
Escribe $fix 'tools/instalar.ps1' "# excluido por barreras -> ley:exento" 'ASCII'           # -> fuera (exento)

$scriptFix = Join-Path $fix 'tools/bandeja.ps1'
$out = (& powershell -NoProfile -File $scriptFix -Repo $fix 2>&1 | Out-String)
$code = $LASTEXITCODE

if ($code -eq 0) { Ok "exit 0 (cola, no muro)" } else { No "esperaba exit 0, fue $code" }
if ($out -match 'HUERFANO' -and $out -match 'suelto\.txt') { Ok "suelto.txt -> HUERFANO (ninguna regla lo cubre)" } else { No "suelto.txt deberia salir como HUERFANO" }
if ($out -match 'SOLO EXISTE' -and $out -match 'docs/analisis/nota\.md') { Ok "docs/analisis/nota.md -> SOLO EXISTE (arbol auditado sin regla)" } else { No "nota.md deberia salir como SOLO EXISTE" }
if ($out -match 'DESVIADO' -and $out -match 'MIDOC\.md') { Ok "MIDOC.md -> DESVIADO (doc capa-2 sin seccion requerida)" } else { No "MIDOC.md deberia salir como DESVIADO" }
if ($out -notmatch 'CONFDOC\.md') { Ok "CONFDOC.md -> fuera de la cola (capa-2 CONFORME, todas las secciones)" } else { No "CONFDOC.md NO deberia estar en la cola (es capa-2 conforme)" }
if ($out -notmatch 'con-contrato\.md') { Ok "con-contrato.md -> fuera de la cola (contrato parametrizado)" } else { No "con-contrato.md NO deberia estar en la cola (tiene contrato)" }
if ($out -match 'ACEPTADOS' -and $out -match 'aceptado\.md' -and $out -match 'Fulano') { Ok "aceptado.md -> fuera de la cola, en ACEPTADOS con firma (badge)" } else { No "aceptado.md deberia salir en ACEPTADOS con la firma Fulano" }
if ($out -notmatch 'algo\.ps1') { Ok "tools/algo.ps1 -> fuera (lo cubre el area barreras)" } else { No "algo.ps1 NO deberia estar en la cola (area barreras lo cubre)" }
if ($out -notmatch 'instalar\.ps1') { Ok "tools/instalar.ps1 -> fuera (ley:exento, excluido por barreras)" } else { No "instalar.ps1 NO deberia estar en la cola (es ley:exento)" }

# ----- -Json (R3-motor): aditivo. La salida es SOLO el JSON {cola,aceptados}, sin texto. -----
# Capturo stdout como BYTES (para el assert de sin-BOM) via ProcessStartInfo.
$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = 'powershell'
$psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$scriptFix`" -Repo `"$fix`" -Json"
$psi.RedirectStandardOutput = $true
$psi.UseShellExecute = $false
$psi.StandardOutputEncoding = New-Object System.Text.UTF8Encoding($false)
$pj = [System.Diagnostics.Process]::Start($psi)
$jsonTxt = $pj.StandardOutput.ReadToEnd()
$pj.WaitForExit()
$jsonExit = $pj.ExitCode
$jsonBytes = (New-Object System.Text.UTF8Encoding($false)).GetBytes($jsonTxt)

if ($jsonExit -eq 0) { Ok "-Json -> exit 0 (mismo exit de siempre)" } else { No "-Json: esperaba exit 0, fue $jsonExit" }
# (c) sin BOM: el primer byte del stdout NO es 0xEF.
if ($jsonBytes.Length -ge 1 -and $jsonBytes[0] -ne 0xEF) { Ok "-Json stdout sin BOM (primer byte no es 0xEF, cross-tool safe)" } else { No "-Json: el stdout empieza con BOM (0xEF) -- rompe parseo" }
# (a) parsea con ConvertFrom-Json y trae las dos claves.
$jparsed = $null
try { $jparsed = $jsonTxt | ConvertFrom-Json } catch { }
if ($jparsed -and $null -ne $jparsed.cola -and $null -ne $jparsed.aceptados) { Ok "-Json parsea a {cola,aceptados}" } else { No "-Json no parsea o le faltan claves cola/aceptados" }
# (b) cola es ARRAY aun con 1+ elementos (trampa PS 5.1: 1 elemento se colapsa a objeto).
#     En el fixture hay >1 pendiente; ademas fuerzo el chequeo de tipo array explicito.
if ($jparsed) {
  $esArray = ($jparsed.cola -is [System.Array]) -or ($jparsed.cola.Count -ge 0 -and $jparsed.cola -isnot [System.Management.Automation.PSCustomObject])
  if ($jparsed.cola -is [System.Array]) { Ok "-Json cola es ARRAY (@() forzo array, no colapso a objeto)" } else { No "-Json cola NO es array (colapso PS 5.1: @() no protegio)" }
  # aceptados: el fixture tiene EXACTAMENTE 1 (aceptado.md) -> el caso critico del colapso.
  if ($jparsed.aceptados -is [System.Array] -and $jparsed.aceptados.Count -eq 1) { Ok "-Json aceptados es ARRAY con 1 elemento (el caso que colapsaria sin @())" } else { No "-Json aceptados deberia ser array de 1 (aceptado.md); es del tipo $($jparsed.aceptados.GetType().Name)" }
}
# (d) SIN -Json la salida de consola no cambio: re-corro sin -Json y confirmo el texto legado.
$outSanidad = (& powershell -NoProfile -File $scriptFix -Repo $fix 2>&1 | Out-String)
if ($outSanidad -match 'Bandeja: pendiente de parametrizar' -and $outSanidad -match 'HUERFANO' -and $outSanidad -notmatch '^\s*\{') { Ok "sin -Json la consola es identica (texto legado, no JSON)" } else { No "sin -Json la salida de consola cambio (aditivo roto)" }

# -Salida HTML: se escribe, sin BOM, con una fila.
$htmlOut = Join-Path $fix 'bandeja.html'
& powershell -NoProfile -File $scriptFix -Repo $fix -Salida $htmlOut 2>&1 | Out-Null
if (Test-Path -LiteralPath $htmlOut) {
  $bytes = [System.IO.File]::ReadAllBytes($htmlOut)
  $bom = ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF)
  if (-not $bom) { Ok "-Salida escribe HTML sin BOM (cross-tool safe)" } else { No "el HTML tiene BOM (rompe deteccion de primera linea)" }
  $htmlTxt = [System.IO.File]::ReadAllText($htmlOut, (New-Object System.Text.UTF8Encoding($false)))
  if ($htmlTxt -match 'MIDOC\.md') { Ok "el HTML lista el caso DESVIADO" } else { No "el HTML deberia listar MIDOC.md" }
} else { No "-Salida no escribio el HTML" }

# no-git: dir sin .git pero con ley valida -> exit 2 (falla cerrado).
$nogit = Join-Path ([System.IO.Path]::GetTempPath()) ("bandeja-nogit-" + [System.Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path (Join-Path $nogit 'tools') -Force | Out-Null
Copy-Item $bandeja (Join-Path $nogit 'tools/bandeja.ps1')
Escribe $nogit 'tools/blast-radius.json' $ley 'ASCII'
& powershell -NoProfile -File (Join-Path $nogit 'tools/bandeja.ps1') -Repo $nogit 2>&1 | Out-Null
$codeNoGit = $LASTEXITCODE
if ($codeNoGit -eq 2) { Ok "no-git -> exit 2 (falla cerrado: sin la foto no pinta cola vacia)" } else { No "no-git: esperaba exit 2, fue $codeNoGit" }

Remove-Item -LiteralPath $fix -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -LiteralPath $nogit -Recurse -Force -ErrorAction SilentlyContinue

# ------------------------------------------------------------------ Parte B (repo REAL)
$outReal = (& powershell -NoProfile -File $bandeja -Repo $raiz 2>&1 | Out-String)
$codeReal = $LASTEXITCODE
if ($codeReal -eq 0) { Ok "Parte B: la cola del repo real corre (exit 0)" } else { No "Parte B: esperaba exit 0, fue $codeReal" }
# Invariante permanente (NO acoplar a un archivo que el flujo normal puede parametrizar y sacar
# de la cola -> romperia el CI al usar la UI): una pieza de motor cubierta por el area barreras
# jamas esta en la cola. Prueba el camino de cobertura-por-area sobre datos reales, sin fragilidad.
if ($outReal -notmatch 'tools/verificar\.ps1') { Ok "Parte B: una pieza de motor (tools/verificar.ps1) NO esta en la cola (la cubre el area barreras)" } else { No "Parte B: tools/verificar.ps1 no deberia estar en la cola (area barreras lo cubre)" }
# product/ NO debe inundar la cola (lo gobierna el grafo de auditar).
if ($outReal -notmatch 'product/capacidades/AND-1') { Ok "Parte B: product/ no inunda la cola (lo gobierna el grafo)" } else { No "Parte B: product/ no deberia salir en la cola (auditar lo gobierna)" }

Write-Host ""
if ($script:fail -gt 0) {
  Write-Host "== Bandeja INCOMPLETA: $($script:fail) fallo(s), $($script:pass) ok. ==" -ForegroundColor Red
  exit 1
}
Write-Host "== Bandeja sana: $($script:pass) verificaciones verdes. ==" -ForegroundColor Green
exit 0
