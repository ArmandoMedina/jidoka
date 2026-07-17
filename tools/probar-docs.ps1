#Requires -Version 5
# probar-docs.ps1 - self-test del detector de conformidad estructural (estado-docs.ps1)
# y del ledger tools/docs-gobernados.json. Dos partes:
#   A) COMPORTAMIENTO: monta un repo-fixture temporal con un ledger y docs de prueba,
#      corre estado-docs.ps1 en proceso aparte y verifica CONFORME/DESVIADO, aditivas-OK,
#      fold de acentos, y el muro OPT-IN (-Estricto -> exit 1 solo si un estricto se desvia).
#   B) INTEGRIDAD (contra el ledger REAL): cada molde referenciado existe; cada 'requerida'
#      es prefijo de algun '## ' del molde (requeridas subset del molde); los 3 docs de
#      instancia inyectados por el ritual estan en el ledger. Ata ledger<->templates sin fundir.
# Se siembra (mecanica). PS 5.1, ASCII a proposito. Ver ADR 0042.

$ErrorActionPreference = 'Stop'
$raiz = Split-Path -Parent $PSScriptRoot
if (-not $raiz) { $raiz = (Get-Location).Path }

$script:pass = 0; $script:fail = 0
function Ok($m) { Write-Host "  [PASA]  $m"; $script:pass++ }
function No($m) { Write-Host "  [FALLA] $m" -ForegroundColor Red; $script:fail++ }

# misma regla de normalizacion que estado-docs.ps1 (fold de acentos via FormD, ASCII-safe).
function Norm($s) {
  $t = ($s -replace '^#{1,6}\s+', '').Trim()
  $t = ($t -replace '\s+', ' ').ToLowerInvariant()
  $d = $t.Normalize([System.Text.NormalizationForm]::FormD)
  $sb = New-Object System.Text.StringBuilder
  foreach ($ch in $d.ToCharArray()) {
    if ([System.Globalization.CharUnicodeInfo]::GetUnicodeCategory($ch) -ne [System.Globalization.UnicodeCategory]::NonSpacingMark) { [void]$sb.Append($ch) }
  }
  return $sb.ToString().Normalize([System.Text.NormalizationForm]::FormC)
}

Write-Host "== Detector de conformidad estructural: comportamiento + integridad =="

# ------------------------------------------------------------------ Parte A
$fix = Join-Path ([System.IO.Path]::GetTempPath()) ("docsgob-" + [System.Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path (Join-Path $fix 'tools') -Force | Out-Null
Copy-Item (Join-Path $PSScriptRoot 'estado-docs.ps1') (Join-Path $fix 'tools/estado-docs.ps1')

# ledger de prueba
$ledgerFix = @'
{
  "capa2": [
    { "doc": "conforme.md",  "molde": "m.md", "requeridas": ["Alpha", "Beta"], "estricto": false },
    { "doc": "faltante.md",  "molde": "m.md", "requeridas": ["Alpha", "Beta"], "estricto": false },
    { "doc": "aditiva.md",   "molde": "m.md", "requeridas": ["Alpha"],         "estricto": false },
    { "doc": "acento.md",    "molde": "m.md", "requeridas": ["Que hace"],      "estricto": false },
    { "doc": "estricto.md",  "molde": "m.md", "requeridas": ["Alpha"],         "estricto": true }
  ],
  "capa3": ["libre.md"]
}
'@
Set-Content -LiteralPath (Join-Path $fix 'tools/docs-gobernados.json') -Value $ledgerFix -Encoding ASCII

# docs-fixture. acento.md lleva 'Que' con e-aguda construida sin literal acentuado (ASCII source).
$eAguda = [char]0x00E9
Set-Content -LiteralPath (Join-Path $fix 'conforme.md') -Value "# t`n## Alpha`ncuerpo`n## Beta`nmas cuerpo" -Encoding UTF8
Set-Content -LiteralPath (Join-Path $fix 'faltante.md') -Value "# t`n## Alpha`nsolo alpha, falta beta" -Encoding UTF8
Set-Content -LiteralPath (Join-Path $fix 'aditiva.md')  -Value "# t`n## Alpha`n## Seccion Extra`ncontenido propio del hijo" -Encoding UTF8
Set-Content -LiteralPath (Join-Path $fix 'acento.md')   -Value ("# t`n## Qu" + $eAguda + " hace (capacidades ancla)`ncuerpo") -Encoding UTF8
Set-Content -LiteralPath (Join-Path $fix 'estricto.md') -Value "# t`n## Otra cosa`nle quitaron Alpha" -Encoding UTF8

$scriptFix = Join-Path $fix 'tools/estado-docs.ps1'

# corrida NO estricta: exit 0 siempre; verifica etiquetas.
$out = (& powershell -NoProfile -File $scriptFix 2>&1 | Out-String)
$code = $LASTEXITCODE
if ($code -eq 0) { Ok "no-estricto: exit 0 (aviso, no muro)" } else { No "no-estricto: esperaba exit 0, fue $code" }
if ($out -match '\[CONFORME\]\s+conforme\.md') { Ok "conforme.md -> CONFORME" } else { No "conforme.md deberia ser CONFORME" }
if ($out -match 'faltante\.md.*falta.*[Bb]eta') { Ok "faltante.md -> DESVIADO nombrando Beta" } else { No "faltante.md deberia DESVIADO por Beta" }
if ($out -match '\[CONFORME\]\s+aditiva\.md') { Ok "aditiva.md -> CONFORME (aditivas OK)" } else { No "aditiva.md deberia ser CONFORME (seccion extra permitida)" }
if ($out -match '\[CONFORME\]\s+acento\.md') { Ok "acento.md -> CONFORME (fold de acentos: 'Que hace' ~ 'Que hace (...)')" } else { No "acento.md deberia CONFORME por fold de acentos + prefijo" }
if ($out -match 'estricto\.md.*falta.*[Aa]lpha') { Ok "estricto.md -> DESVIADO nombrando Alpha" } else { No "estricto.md deberia DESVIADO por Alpha" }

# corrida ESTRICTA: estricto.md desviado -> exit 1 (muro opt-in).
& powershell -NoProfile -File $scriptFix -Estricto 2>&1 | Out-Null
$codeE = $LASTEXITCODE
if ($codeE -eq 1) { Ok "-Estricto con un doc estricto desviado -> exit 1 (muro opt-in muerde)" } else { No "-Estricto: esperaba exit 1, fue $codeE" }

# el mismo fixture pero SIN el estricto desviado debe salir 0 aun en -Estricto:
Set-Content -LiteralPath (Join-Path $fix 'estricto.md') -Value "# t`n## Alpha`nahora si trae Alpha" -Encoding UTF8
& powershell -NoProfile -File $scriptFix -Estricto 2>&1 | Out-Null
$codeE2 = $LASTEXITCODE
if ($codeE2 -eq 0) { Ok "-Estricto sin estrictos desviados -> exit 0 (no bloquea de mas)" } else { No "-Estricto sano: esperaba exit 0, fue $codeE2" }

Remove-Item -LiteralPath $fix -Recurse -Force -ErrorAction SilentlyContinue

# ------------------------------------------------------------------ Parte B (ledger REAL)
$ledgerReal = Join-Path $raiz 'tools/docs-gobernados.json'
if (-not (Test-Path $ledgerReal)) { No "no existe tools/docs-gobernados.json (el ledger real)"; }
else {
  $L = Get-Content -LiteralPath $ledgerReal -Raw | ConvertFrom-Json
  foreach ($e in $L.capa2) {
    $moldeAbs = Join-Path $raiz $e.molde
    if (-not (Test-Path -LiteralPath $moldeAbs)) { No "molde ausente: $($e.molde) (doc $($e.doc))"; continue }
    Ok "molde existe: $($e.molde)"
    # requeridas subset del molde (por prefijo normalizado)
    $heads = @()
    foreach ($ln in [System.IO.File]::ReadAllLines($moldeAbs)) { if ($ln -match '^##[^#]') { $heads += (Norm $ln) } }
    foreach ($req in $e.requeridas) {
      $rn = Norm $req; $hit = $false
      foreach ($h in $heads) { if ($h.StartsWith($rn)) { $hit = $true; break } }
      if ($hit) { Ok "requerida '$req' esta en el molde de $($e.doc)" } else { No "requerida '$req' NO aparece en su molde $($e.molde) (contrato imposible)" }
    }
  }
  # los 3 docs de instancia que el ritual inyecta deben estar gobernados.
  $inyectados = @('CONTRIBUTING.md', 'product/PRODUCT_BRIEF.md', 'product/infra.md')
  $docs = @($L.capa2 | ForEach-Object { $_.doc })
  foreach ($iny in $inyectados) {
    if ($docs -contains $iny) { Ok "doc inyectado gobernado: $iny" } else { No "el ritual inyecta $iny con @ pero NO esta en el ledger capa2" }
  }
}

Write-Host ""
if ($script:fail -gt 0) {
  Write-Host "== Detector INCOMPLETO: $($script:fail) fallo(s), $($script:pass) ok. ==" -ForegroundColor Red
  exit 1
}
Write-Host "== Detector sano: $($script:pass) verificaciones verdes. =="
exit 0
