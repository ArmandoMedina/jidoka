#Requires -Version 5
# probar-instalador.ps1 - smoke del instalador (disparo prueba-de-humo-del-gate).
# Instala Jidoka en un repo git TEMPORAL, commitea, y corre los self-tests SEMBRADOS
# + verificar ahi: un instalador que siembra un motor roto se caza aqui. Verifica
# tambien el NO-CLOBBER (una segunda corrida no pisa un archivo con trabajo).
#
# Uso:  ./tools/probar-instalador.ps1   (exit 0 = instalador sano; exit 1 = bug)
# Nota: archivo ASCII a proposito, PS 5.1.

$instalar = Join-Path $PSScriptRoot 'instalar.ps1'
$script:fallos = 0
$script:casos = 0

function Check($nombre, $cond, $detalle) {
  $script:casos++
  if ($cond) { Write-Host "  [PASA]  $nombre" -ForegroundColor Green }
  else { Write-Host "  [FALLA] $nombre ($detalle)" -ForegroundColor Red; $script:fallos++ }
}

function Run-PS($file) {
  & powershell -NoProfile -ExecutionPolicy Bypass -File $file @args *> $null
  return $LASTEXITCODE
}

Write-Host "== Smoke del instalador (tools/instalar.ps1) =="
$tmp = Join-Path $env:TEMP ("jidoka-smoke-" + [guid]::NewGuid().ToString('N').Substring(0,8))

try {
  # 1. Instalar en el temporal.
  Run-PS $instalar -Destino $tmp -Arquetipo 'docs-as-code' -Yes | Out-Null
  Check 'instala: el motor queda sembrado' (Test-Path (Join-Path $tmp 'tools/verificar.ps1')) "no aparecio tools/verificar.ps1"
  Check 'instala: la ley del arquetipo queda sembrada' (Test-Path (Join-Path $tmp 'tools/blast-radius.json')) "no aparecio la ley"
  Check 'instala: los comandos /jidoka:* quedan sembrados' (Test-Path (Join-Path $tmp '.claude/commands/jidoka/arranca.md')) "no aparecio arranca.md"
  Check 'instala: core.hooksPath quedo configurado' ((git -C $tmp config core.hooksPath) -eq '.githooks') "hooksPath no quedo"

  # 1b. SELLO de version: el hijo sabe de que Jidoka viene su motor, con hashes que casan.
  $selloPath = Join-Path $tmp 'tools/jidoka-motor.json'
  Check 'sello: tools/jidoka-motor.json queda sembrado' (Test-Path $selloPath) "no aparecio el sello"
  $verTxt = (Get-Content (Join-Path $PSScriptRoot 'version.txt') -Raw).Trim()
  $selloVerOk = $false; $hashesOk = $false; $countOk = $false
  if (Test-Path $selloPath) {
    try {
      $sello = Get-Content $selloPath -Raw | ConvertFrom-Json
      $selloVerOk = ($sello.version -eq $verTxt)
      $props = @($sello.sembrado_hashes.PSObject.Properties)
      $countOk = ($props.Count -gt 0)
      $hashesOk = $true
      foreach ($p in $props) {
        $abs = Join-Path $tmp $p.Name
        if (-not (Test-Path -LiteralPath $abs) -or ((Get-FileHash -LiteralPath $abs -Algorithm SHA256).Hash -ne $p.Value)) { $hashesOk = $false; break }
      }
    } catch {}
  }
  Check 'sello: version == tools/version.txt' $selloVerOk "sello.version != $verTxt"
  Check 'sello: registra al menos una pieza de motor' $countOk "sembrado_hashes vacio"
  Check 'sello: cada hash casa con el archivo sembrado' $hashesOk "algun hash no coincide con lo sembrado"

  # 2. Commit inicial (un repo recien sembrado se commitea antes de que verificar mida).
  Push-Location $tmp
  git add -A 2>&1 | Out-Null
  git -c user.email='smoke@jidoka.local' -c user.name='smoke' -c commit.gpgsign=false commit -q -m 'sembrado inicial' 2>&1 | Out-Null
  Pop-Location

  # 3. Los self-tests SEMBRADOS deben pasar en el destino.
  foreach ($t in @('probar-gate', 'probar-hooks', 'probar-auditor')) {
    $code = Run-PS (Join-Path $tmp "tools/$t.ps1")
    Check "self-test sembrado '$t' pasa en el destino" ($code -eq 0) "exit $code"
  }

  # 4. verificar sembrado corre limpio (con HEAD ya existente).
  $vc = Run-PS (Join-Path $tmp 'tools/verificar.ps1')
  Check 'verificar sembrado corre limpio (exit 0)' ($vc -eq 0) "exit $vc"

  # 5. NO-CLOBBER: escribo trabajo propio y re-instalo; no debe pisarse.
  $handoff = Join-Path $tmp 'HANDOFF.md'
  $marca = 'CONTENIDO-PROPIO-QUE-NO-SE-DEBE-PISAR'
  Set-Content -Path $handoff -Value $marca -Encoding UTF8
  Run-PS $instalar -Destino $tmp -Yes | Out-Null
  $after = Get-Content $handoff -Raw
  Check 'no-clobber: la segunda instalacion NO pisa un archivo existente' ($after -match $marca) "el archivo se sobrescribio"

  # 5b. -ACTUALIZAR con conciencia de tres vias. Monto tres situaciones a la vez:
  #   (a) probar-hooks.ps1: lo modifico Y ajusto el sello para que el hash sembrado
  #       case con lo modificado -> el hijo "no lo toco" desde la siembra pero Jidoka
  #       difiere -> debe ACTUALIZARse (restaurarse a la version de Jidoka).
  #   (b) auditar.ps1: lo modifico SIN tocar el sello -> el hijo lo customizo ->
  #       DIVERGENCIA: no se pisa, se deja el .jidoka-nuevo.
  #   (c) HANDOFF.md (instancia, con la marca del paso 5) -> intacto siempre.
  $hookChild = Join-Path $tmp 'tools/probar-hooks.ps1'
  $audChild  = Join-Path $tmp 'tools/auditar.ps1'
  Add-Content -Path $hookChild -Value '# tweak que Jidoka no tiene'
  $selloObj = Get-Content $selloPath -Raw | ConvertFrom-Json
  $selloObj.sembrado_hashes.'tools/probar-hooks.ps1' = (Get-FileHash -LiteralPath $hookChild -Algorithm SHA256).Hash
  [System.IO.File]::WriteAllText($selloPath, ($selloObj | ConvertTo-Json -Depth 5), (New-Object System.Text.UTF8Encoding($false)))
  Add-Content -Path $audChild -Value '# ajuste propio del hijo'

  Run-PS $instalar -Destino $tmp -Actualizar | Out-Null
  $hookRestaurado = -not ((Get-Content $hookChild -Raw) -match 'tweak que Jidoka no tiene')
  Check 'actualizar: restaura una pieza NO customizada (hijo==sello, Jidoka avanzo)' $hookRestaurado "probar-hooks.ps1 no se restauro"
  $audPreservado = ((Get-Content $audChild -Raw) -match 'ajuste propio del hijo')
  Check 'actualizar: NO pisa una pieza divergente (hijo la customizo)' $audPreservado "auditar.ps1 se piso"
  Check 'actualizar: deja <archivo>.jidoka-nuevo para la divergencia' (Test-Path "$audChild.jidoka-nuevo") "no aparecio el .jidoka-nuevo"
  Check 'actualizar: la instancia (HANDOFF) queda intacta' ((Get-Content $handoff -Raw) -match $marca) "se toco HANDOFF"
  $selloDespues = Get-Content $selloPath -Raw | ConvertFrom-Json
  Check 'actualizar: el sello queda en la version de Jidoka' ($selloDespues.version -eq $verTxt) "version quedo $($selloDespues.version)"
  $jidokaAudHash = (Get-FileHash -LiteralPath (Join-Path $PSScriptRoot 'auditar.ps1') -Algorithm SHA256).Hash
  Check 'actualizar: el sello guarda el hash que Jidoka ENVIA (no el custom del hijo)' ($selloDespues.sembrado_hashes.'tools/auditar.ps1' -eq $jidokaAudHash) "el sello no guardo el hash de Jidoka"

  # 5c. Segunda corrida: la divergencia persiste hasta reconciliar; lo restaurado ya esta al dia.
  Run-PS $instalar -Destino $tmp -Actualizar | Out-Null
  $persiste = ((Get-Content $audChild -Raw) -match 'ajuste propio del hijo') -and (Test-Path "$audChild.jidoka-nuevo")
  Check 'actualizar (2a vez): la divergencia persiste, lo demas converge' $persiste "no fue idempotente"

  # 6. Segundo arquetipo: code-first siembra DISTINTO (brief, no grafo) y su gate pasa.
  $tmp2 = Join-Path $env:TEMP ("jidoka-smoke2-" + [guid]::NewGuid().ToString('N').Substring(0,8))
  try {
    Run-PS $instalar -Destino $tmp2 -Arquetipo 'code-first' -Yes | Out-Null
    $brief = (Test-Path (Join-Path $tmp2 'PRODUCT_BRIEF.md'))
    $grafo = (Test-Path (Join-Path $tmp2 'product/README.md'))
    Check 'code-first: siembra PRODUCT_BRIEF y NO el grafo de notas' ($brief -and -not $grafo) "brief=$brief grafo=$grafo"
    $leyOk = $false
    try { Get-Content (Join-Path $tmp2 'tools/blast-radius.json') -Raw | ConvertFrom-Json | Out-Null; $leyOk = $true } catch {}
    Check 'code-first: su ley parsea' $leyOk "la ley code-first no parsea"
    Push-Location $tmp2
    git add -A 2>&1 | Out-Null
    git -c user.email='smoke@jidoka.local' -c user.name='smoke' -c commit.gpgsign=false commit -q -m 'sembrado' 2>&1 | Out-Null
    Pop-Location
    $gc = Run-PS (Join-Path $tmp2 'tools/probar-gate.ps1')
    Check 'code-first: el gate sembrado pasa en el destino' ($gc -eq 0) "exit $gc"
  }
  finally { Remove-Item $tmp2 -Recurse -Force -ErrorAction SilentlyContinue }
}
finally {
  Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host ""
if ($script:fallos -gt 0) {
  Write-Host "== $($script:fallos) de $($script:casos) caso(s) fallidos. El instalador tiene un bug: no lo estrenes. ==" -ForegroundColor Red
  exit 1
}
Write-Host "== Instalador sano: los $($script:casos) casos se comportan como se espera. ==" -ForegroundColor Green
exit 0
