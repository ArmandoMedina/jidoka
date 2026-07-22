#Requires -Version 5
# probar-sembrar.ps1 - smoke del fallback de siembra (tools/sembrar-manual.ps1) y de la
# degradacion con gracia de estado-motor.ps1 (jidoka#40/#43; ADR 0027). Verifica que el
# fallback deja el motor en el MISMO estado que instalar.ps1 (motor + ley + sello + hooks),
# que el sello es identico (version + hashes que casan), que respeta no-clobber y las tres
# vias en -Actualizar, y que estado-motor apunta al fallback cuando instalar.ps1 no es legible.
#
# Uso:  ./tools/probar-sembrar.ps1   (exit 0 = fallback sano; exit 1 = bug). Jidoka-only
# (no se siembra en los hijos). Nota: archivo ASCII a proposito, PS 5.1.

$sembrar   = Join-Path $PSScriptRoot 'sembrar-manual.ps1'
$jidoka    = Split-Path -Parent $PSScriptRoot
$verTxt    = (Get-Content (Join-Path $PSScriptRoot 'version.txt') -Raw).Trim()
$script:fallos = 0
$script:casos  = 0

function Check($nombre, $cond, $detalle) {
  $script:casos++
  if ($cond) { Write-Host "  [PASA]  $nombre" -ForegroundColor Green }
  else { Write-Host "  [FALLA] $nombre ($detalle)" -ForegroundColor Red; $script:fallos++ }
}
function Run-PS($file) { & powershell -NoProfile -ExecutionPolicy Bypass -File $file @args *> $null; return $LASTEXITCODE }
function Run-PS-Out($file) { return (& powershell -NoProfile -ExecutionPolicy Bypass -File $file @args 2>&1 | Out-String) }
function Get-HashLF($path) {
  $bytes = [System.IO.File]::ReadAllBytes($path)
  $sinCR = New-Object System.Collections.Generic.List[byte]
  foreach ($b in $bytes) { if ($b -ne 13) { $sinCR.Add($b) } }
  $sha = [System.Security.Cryptography.SHA256]::Create()
  try { $h = $sha.ComputeHash($sinCR.ToArray()) } finally { $sha.Dispose() }
  return ([System.BitConverter]::ToString($h) -replace '-', '')
}

Write-Host "== Smoke del fallback de siembra (tools/sembrar-manual.ps1) =="
$tmp = Join-Path $env:TEMP ("jidoka-sembrar-" + [guid]::NewGuid().ToString('N').Substring(0,8))

try {
  # 1. SIEMBRA FRESCA: deja el motor + la ley + el sello + hooksPath, sin instalar.ps1.
  Run-PS $sembrar -Destino $tmp -Jidoka $jidoka | Out-Null
  Check 'siembra: el motor queda sembrado (verificar.ps1)' (Test-Path (Join-Path $tmp 'tools/verificar.ps1')) "no aparecio verificar.ps1"
  Check 'siembra: el propio fallback queda sembrado (sembrar-manual.ps1)' (Test-Path (Join-Path $tmp 'tools/sembrar-manual.ps1')) "no aparecio sembrar-manual.ps1"
  Check 'siembra: la ley del arquetipo queda sembrada' (Test-Path (Join-Path $tmp 'tools/blast-radius.json')) "no aparecio la ley"
  Check 'siembra: los comandos /jidoka:* quedan sembrados' (Test-Path (Join-Path $tmp '.claude/commands/jidoka/arranca.md')) "no aparecio arranca.md"
  # Cosecha #7 (issue #87): los agentes-asiento viajan tambien por el fallback AV-seguro (+ su lint).
  foreach ($ag in 'explorador','mecanico','auditor','arquitecto') {
    Check "siembra: el agente-asiento '$ag' queda sembrado" (Test-Path (Join-Path $tmp ".claude/agents/$ag.md")) "no aparecio .claude/agents/$ag.md"
  }
  Check 'siembra: el lint de agentes queda sembrado (probar-agentes.ps1)' (Test-Path (Join-Path $tmp 'tools/probar-agentes.ps1')) "no aparecio probar-agentes.ps1"
  Check 'siembra: core.hooksPath quedo configurado' ((git -C $tmp config core.hooksPath) -eq '.githooks') "hooksPath no quedo"
  # Stubs de instancia: el fallback ahora siembra la instancia completa (no-clobber), no solo
  # la mecanica -- para que un hijo en maquina donde instalar.ps1 cae en cuarentena no quede
  # a medias (jidoka#40/#43, ADR 0027 enmienda). docs-as-code -> producto 'grafo' -> product/.
  Check 'siembra: los stubs de instancia comunes quedan sembrados (HANDOFF)' (Test-Path (Join-Path $tmp 'HANDOFF.md')) "no aparecio HANDOFF.md"
  # Cosecha #7 (issue #86): la instancia que el arranca inyecta viaja como stub comun.
  Check 'siembra: el brief queda en product/ (lo inyecta el arranca)' (Test-Path (Join-Path $tmp 'product/PRODUCT_BRIEF.md')) "no aparecio product/PRODUCT_BRIEF.md"
  $infraStubS = Join-Path $tmp 'product/infra.md'
  Check 'siembra: product/infra.md trae la seccion del casting' ((Test-Path $infraStubS) -and ((Get-Content $infraStubS -Raw) -match '## El casting')) "infra.md ausente o sin ## El casting"
  Check 'siembra: CONTRIBUTING.md queda sembrado' (Test-Path (Join-Path $tmp 'CONTRIBUTING.md')) "no aparecio CONTRIBUTING.md"
  Check 'siembra: la semilla del QUE del arquetipo queda sembrada (grafo -> product/README)' (Test-Path (Join-Path $tmp 'product/README.md')) "no aparecio product/README.md"

  # 1b. SELLO identico al que deja instalar.ps1: version + cada hash casa con lo sembrado.
  $selloPath = Join-Path $tmp 'tools/jidoka-motor.json'
  Check 'sello: tools/jidoka-motor.json queda escrito' (Test-Path $selloPath) "no aparecio el sello"
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
        if (-not (Test-Path -LiteralPath $abs) -or ((Get-HashLF $abs) -ne $p.Value)) { $hashesOk = $false; break }
      }
    } catch {}
  }
  Check 'sello: version == tools/version.txt' $selloVerOk "sello.version != $verTxt"
  Check 'sello: registra al menos una pieza de motor' $countOk "sembrado_hashes vacio"
  Check 'sello: cada hash casa con el archivo sembrado' $hashesOk "algun hash no coincide"
  # 1d. SELLO.PRODUCTO: la siembra fresca docs-as-code debe escribir producto='grafo'.
  #     Reusa $sello ya parseado en 1b: una sola lectura, y si el JSON no parseo la causa ya es visible ahi.
  $prodOk = [bool]($sello -and $sello.producto -eq 'grafo')
  Check 'sello: producto == grafo (arquetipo docs-as-code)' $prodOk "sello.producto no es 'grafo' (docs-as-code)"

  # 1e. SELLO.PRODUCTO para code-first: producto debe ser 'brief'.
  $tmpCF = Join-Path $env:TEMP ("jidoka-sembrarCF-" + [guid]::NewGuid().ToString('N').Substring(0,8))
  try {
    Run-PS $sembrar -Destino $tmpCF -Jidoka $jidoka -Arquetipo code-first | Out-Null
    $selloCFPath = Join-Path $tmpCF 'tools/jidoka-motor.json'
    $prodCFOk = $false
    if (Test-Path $selloCFPath) {
      try { $sc = Get-Content $selloCFPath -Raw | ConvertFrom-Json; $prodCFOk = ($sc.producto -eq 'brief') } catch {}
    }
    Check 'sello: producto == brief (arquetipo code-first)' $prodCFOk "sello.producto no es 'brief' (code-first)"
  }
  finally { Remove-Item $tmpCF -Recurse -Force -ErrorAction SilentlyContinue }

  # 1c. ESTADO-MOTOR contra el Jidoka real: debe decir [OK] al dia (criterio de aceptacion).
  $em = Join-Path $tmp 'tools/estado-motor.ps1'
  $emOut = Run-PS-Out $em -Jidoka $jidoka
  Check 'estado-motor: tras el fallback, reporta [OK] al dia' ($emOut -match '\[OK\]') "no dio el OK: $emOut"

  # 2. Los self-tests SEMBRADOS pasan en el destino (el fallback no siembra un motor roto).
  Push-Location $tmp
  git add -A 2>&1 | Out-Null
  git -c user.email='smoke@jidoka.local' -c user.name='smoke' -c commit.gpgsign=false commit -q -m 'sembrado fallback' 2>&1 | Out-Null
  Pop-Location
  foreach ($t in @('probar-gate', 'probar-hooks', 'probar-auditor', 'probar-disparos', 'probar-adrs')) {
    $code = Run-PS (Join-Path $tmp "tools/$t.ps1")
    Check "self-test sembrado '$t' pasa en el destino" ($code -eq 0) "exit $code"
  }

  # 3. -ACTUALIZAR con tres vias (misma semantica que instalar.ps1):
  #   (a) probar-hooks.ps1: lo modifico Y ajusto el sello para que case -> el hijo NO lo
  #       toco desde la siembra pero Jidoka difiere -> debe ACTUALIZARse.
  #   (b) auditar.ps1: lo modifico SIN tocar el sello -> el hijo lo customizo -> DIVERGE.
  $hookChild = Join-Path $tmp 'tools/probar-hooks.ps1'
  $audChild  = Join-Path $tmp 'tools/auditar.ps1'
  Add-Content -Path $hookChild -Value '# tweak que Jidoka no tiene'
  $selloObj = Get-Content $selloPath -Raw | ConvertFrom-Json
  $selloObj.sembrado_hashes.'tools/probar-hooks.ps1' = (Get-HashLF $hookChild)
  [System.IO.File]::WriteAllText($selloPath, ($selloObj | ConvertTo-Json -Depth 5), (New-Object System.Text.UTF8Encoding($false)))
  Add-Content -Path $audChild -Value '# ajuste propio del hijo'

  Run-PS $sembrar -Destino $tmp -Jidoka $jidoka -Actualizar | Out-Null
  $hookRestaurado = -not ((Get-Content $hookChild -Raw) -match 'tweak que Jidoka no tiene')
  Check 'actualizar: restaura una pieza NO customizada (hijo==sello, Jidoka avanzo)' $hookRestaurado "probar-hooks.ps1 no se restauro"
  $audPreservado = ((Get-Content $audChild -Raw) -match 'ajuste propio del hijo')
  Check 'actualizar: NO pisa una pieza divergente (hijo la customizo)' $audPreservado "auditar.ps1 se piso"
  Check 'actualizar: deja <archivo>.jidoka-nuevo para la divergencia' (Test-Path "$audChild.jidoka-nuevo") "no aparecio el .jidoka-nuevo"
  $selloDespues = Get-Content $selloPath -Raw | ConvertFrom-Json
  $jidokaAudHash = (Get-HashLF (Join-Path $PSScriptRoot 'auditar.ps1'))
  Check 'actualizar: el sello guarda el hash que Jidoka ENVIA (no el custom del hijo)' ($selloDespues.sembrado_hashes.'tools/auditar.ps1' -eq $jidokaAudHash) "el sello no guardo el hash de Jidoka"

  # 4. NO-CLOBBER en siembra fresca sobre brownfield: una pieza YA customizada se preserva
  #    y NO se registra en el sello (asi un -Actualizar posterior la vera DIVERGE, no la pisa).
  $tmpBf = Join-Path $env:TEMP ("jidoka-sembrarBf-" + [guid]::NewGuid().ToString('N').Substring(0,8))
  try {
    New-Item -ItemType Directory -Path (Join-Path $tmpBf 'tools') -Force | Out-Null
    $bfVerif = Join-Path $tmpBf 'tools/verificar.ps1'
    Set-Content -Path $bfVerif -Value '# verificar CUSTOMIZADO del hijo (brownfield)' -Encoding ASCII
    Run-PS $sembrar -Destino $tmpBf -Jidoka $jidoka | Out-Null
    Check 'brownfield: no-clobber preserva la pieza customizada' ((Get-Content $bfVerif -Raw) -match 'CUSTOMIZADO del hijo') "se piso la pieza customizada"
    $selloBf = Get-Content (Join-Path $tmpBf 'tools/jidoka-motor.json') -Raw | ConvertFrom-Json
    Check 'brownfield: el sello NO registra la pieza customizada' (-not $selloBf.sembrado_hashes.'tools/verificar.ps1') "registro el hash del hijo como semilla"
    Check 'brownfield: el sello SI registra una pieza pristina recien sembrada' ([bool]$selloBf.sembrado_hashes.'tools/auditar.ps1') "no registro una pristina"
  }
  finally { Remove-Item $tmpBf -Recurse -Force -ErrorAction SilentlyContinue }

  # 5. -Actualizar sin sello previo muere con guia (no es un hijo ya sembrado).
  $tmpVacio = Join-Path $env:TEMP ("jidoka-sembrarVacio-" + [guid]::NewGuid().ToString('N').Substring(0,8))
  try {
    New-Item -ItemType Directory -Path $tmpVacio -Force | Out-Null
    $code = Run-PS $sembrar -Destino $tmpVacio -Jidoka $jidoka -Actualizar
    Check 'actualizar sin sello: falla con exit 1 (guia a siembra inicial)' ($code -eq 1) "exit $code (esperaba 1)"
  }
  finally { Remove-Item $tmpVacio -Recurse -Force -ErrorAction SilentlyContinue }

  # 6. DEGRADACION CON GRACIA de estado-motor (ADR 0027): ante divergencia, recomienda
  #    instalar.ps1 si es legible, o sembrar-manual.ps1 si no lo es (AV lo bloqueo).
  #    (a) Jidoka FALSO mas nuevo CON instalar.ps1 legible -> recomienda instalar.ps1.
  $fakeConInst = Join-Path $env:TEMP ("jidoka-fakeInst-" + [guid]::NewGuid().ToString('N').Substring(0,6))
  New-Item -ItemType Directory -Path (Join-Path $fakeConInst 'tools') -Force | Out-Null
  Set-Content -Path (Join-Path $fakeConInst 'tools/version.txt') -Value '9.9.9-nuevo' -Encoding ASCII
  Set-Content -Path (Join-Path $fakeConInst 'tools/instalar.ps1') -Value '# instalador de mentira, legible' -Encoding ASCII
  $out6a = Run-PS-Out $em -Jidoka $fakeConInst
  Check 'degradacion: con instalar.ps1 legible, recomienda instalar.ps1 -Actualizar' (($out6a -match 'AVISO') -and ($out6a -match 'instalar\.ps1 -Destino') -and ($out6a -notmatch 'sembrar-manual')) "no recomendo instalar.ps1: $out6a"
  Remove-Item $fakeConInst -Recurse -Force -ErrorAction SilentlyContinue

  #    (b) Jidoka FALSO mas nuevo SIN instalar.ps1 (simula el AV que lo bloquea) ->
  #        recomienda el fallback sembrar-manual.ps1.
  $fakeSinInst = Join-Path $env:TEMP ("jidoka-fakeSinInst-" + [guid]::NewGuid().ToString('N').Substring(0,6))
  New-Item -ItemType Directory -Path (Join-Path $fakeSinInst 'tools') -Force | Out-Null
  Set-Content -Path (Join-Path $fakeSinInst 'tools/version.txt') -Value '9.9.9-nuevo' -Encoding ASCII
  $out6b = Run-PS-Out $em -Jidoka $fakeSinInst
  Check 'degradacion: sin instalar.ps1 legible, apunta al fallback sembrar-manual.ps1' (($out6b -match 'AVISO') -and ($out6b -match 'sembrar-manual\.ps1')) "no apunto al fallback: $out6b"
  Remove-Item $fakeSinInst -Recurse -Force -ErrorAction SilentlyContinue

  # 7. GUARD del manifiesto sin 'stubs' (cosecha #7, issue #89): un checkout de Jidoka
  #    viejo (o un manifiesto parcial) sin el campo 'stubs' NO revienta la siembra a
  #    medias -- en PS 5.1 @($null) no es vacio y el foreach llegaba a Join-Path con
  #    $null.ruta, dejando mecanica copiada pero sin sello (el estado a-medias de #40/#43).
  $fakeSinStubs = Join-Path $env:TEMP ("jidoka-fakeSinStubs-" + [guid]::NewGuid().ToString('N').Substring(0,6))
  $tmpSinStubs  = Join-Path $env:TEMP ("jidoka-sembrarSS-" + [guid]::NewGuid().ToString('N').Substring(0,8))
  try {
    New-Item -ItemType Directory -Path (Join-Path $fakeSinStubs 'kit/.jidoka/instalar') -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $fakeSinStubs 'kit/.jidoka/leyes') -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $fakeSinStubs 'tools') -Force | Out-Null
    Set-Content -Path (Join-Path $fakeSinStubs 'tools/version.txt') -Value '9.9.9-sinstubs' -Encoding ASCII
    Copy-Item (Join-Path $jidoka 'kit/.jidoka/leyes/blast-radius.docs-as-code.json') (Join-Path $fakeSinStubs 'kit/.jidoka/leyes/blast-radius.docs-as-code.json') -Force
    $manifSin = Get-Content (Join-Path $jidoka 'kit/.jidoka/instalar/manifiesto.json') -Raw | ConvertFrom-Json
    $manifSin.PSObject.Properties.Remove('stubs')
    [System.IO.File]::WriteAllText((Join-Path $fakeSinStubs 'kit/.jidoka/instalar/manifiesto.json'), ($manifSin | ConvertTo-Json -Depth 10), (New-Object System.Text.UTF8Encoding($false)))
    $codeSin = Run-PS $sembrar -Destino $tmpSinStubs -Jidoka $fakeSinStubs
    Check 'guard #89: manifiesto sin stubs NO revienta la siembra (exit 0)' ($codeSin -eq 0) "exit $codeSin (esperaba 0)"
    Check 'guard #89: la siembra llega hasta el sello (no quedo a medias)' (Test-Path (Join-Path $tmpSinStubs 'tools/jidoka-motor.json')) "no aparecio el sello"
  }
  finally {
    Remove-Item $fakeSinStubs -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item $tmpSinStubs -Recurse -Force -ErrorAction SilentlyContinue
  }
}
finally {
  Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host ""
if ($script:fallos -gt 0) {
  Write-Host "== $($script:fallos) de $($script:casos) caso(s) fallidos. El fallback tiene un bug: no lo estrenes. ==" -ForegroundColor Red
  exit 1
}
Write-Host "== Fallback sano: los $($script:casos) casos se comportan como se espera. ==" -ForegroundColor Green
exit 0
