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

# Como Run-PS pero devuelve la salida (para inspeccionar avisos, no solo el exit).
function Run-PS-Out($file) {
  return (& powershell -NoProfile -ExecutionPolicy Bypass -File $file @args 2>&1 | Out-String)
}

# SHA256 normalizado a LF (mismo hasheo agnostico-al-EOL que instalar.ps1/estado-motor;
# ADR 0021). El self-test setea/compara hashes del sello, y deben casar el del instalador.
function Get-HashLF($path) {
  $bytes = [System.IO.File]::ReadAllBytes($path)
  $sinCR = New-Object System.Collections.Generic.List[byte]
  foreach ($b in $bytes) { if ($b -ne 13) { $sinCR.Add($b) } }
  $sha = [System.Security.Cryptography.SHA256]::Create()
  try { $h = $sha.ComputeHash($sinCR.ToArray()) } finally { $sha.Dispose() }
  return ([System.BitConverter]::ToString($h) -replace '-', '')
}

Write-Host "== Smoke del instalador (tools/instalar.ps1) =="
$tmp = Join-Path $env:TEMP ("jidoka-smoke-" + [guid]::NewGuid().ToString('N').Substring(0,8))

try {
  # 1. Instalar en el temporal.
  $salidaInstala = Run-PS-Out $instalar -Destino $tmp -Arquetipo 'docs-as-code' -Yes
  Check 'instala: el motor queda sembrado' (Test-Path (Join-Path $tmp 'tools/verificar.ps1')) "no aparecio tools/verificar.ps1"
  # Sprint 26: el cierre de la instalacion GRITA que el muro server-side aun no
  # muerde (post.aviso del manifiesto). Sin este caso, quitar el aviso pasaria verde.
  Check 'instala: imprime el aviso "el muro server-side AUN NO muerde" (post.aviso)' (($salidaInstala -join "`n") -match 'muro server-side AUN NO muerde') "el aviso post-instalar no aparecio en la salida"
  Check 'instala: la ley del arquetipo queda sembrada' (Test-Path (Join-Path $tmp 'tools/blast-radius.json')) "no aparecio la ley"
  Check 'instala: los comandos /jidoka:* quedan sembrados' (Test-Path (Join-Path $tmp '.claude/commands/jidoka/arranca.md')) "no aparecio arranca.md"
  # Cosecha #7 (issue #87): los agentes-asiento del ADR 0033 viajan en el kit -- el arranca
  # sembrado los referencia, asi que la siembra debe entregarlos (los 4) + su lint.
  foreach ($ag in 'explorador','mecanico','auditor','arquitecto') {
    Check "instala: el agente-asiento '$ag' queda sembrado" (Test-Path (Join-Path $tmp ".claude/agents/$ag.md")) "no aparecio .claude/agents/$ag.md"
  }
  Check 'instala: el lint de agentes queda sembrado (probar-agentes.ps1)' (Test-Path (Join-Path $tmp 'tools/probar-agentes.ps1')) "no aparecio probar-agentes.ps1"
  # Cosecha #7 (issue #86): la instancia que el arranca inyecta es stub COMUN a todo
  # arquetipo (brief + infra + CONTRIBUTING, en las rutas que el arranca inyecta) --
  # sin ellos la sesion del hijo abre con @ rotos.
  Check 'instala: el brief queda en product/ (lo inyecta el arranca)' (Test-Path (Join-Path $tmp 'product/PRODUCT_BRIEF.md')) "no aparecio product/PRODUCT_BRIEF.md"
  Check 'instala: NO deja PRODUCT_BRIEF.md en la raiz (ruta vieja)' (-not (Test-Path (Join-Path $tmp 'PRODUCT_BRIEF.md'))) "aparecio PRODUCT_BRIEF.md en la raiz"
  $infraStub = Join-Path $tmp 'product/infra.md'
  Check 'instala: product/infra.md queda sembrado' (Test-Path $infraStub) "no aparecio product/infra.md"
  Check 'instala: infra.md trae la seccion del casting (la casa unica del roster)' ((Test-Path $infraStub) -and ((Get-Content $infraStub -Raw) -match '## El casting')) "infra.md sin ## El casting"
  Check 'instala: CONTRIBUTING.md queda sembrado' (Test-Path (Join-Path $tmp 'CONTRIBUTING.md')) "no aparecio CONTRIBUTING.md"
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
        if (-not (Test-Path -LiteralPath $abs) -or ((Get-HashLF $abs) -ne $p.Value)) { $hashesOk = $false; break }
      }
    } catch {}
  }
  Check 'sello: version == tools/version.txt' $selloVerOk "sello.version != $verTxt"
  Check 'sello: registra al menos una pieza de motor' $countOk "sembrado_hashes vacio"
  Check 'sello: cada hash casa con el archivo sembrado' $hashesOk "algun hash no coincide con lo sembrado"
  # Issue #91 (cosecha #7): el sello se escribe CON newline final -- sin el, todo diff
  # futuro del hijo arrastra el marcador "No newline at end of file".
  Check 'sello: termina con newline final (#91)' ((Test-Path $selloPath) -and ([System.IO.File]::ReadAllText($selloPath)).EndsWith("`n")) "el sello no termina en newline"

  # 1f. ENLACES DE METODO: ningun doc sembrado debe citar un doc de metodo ausente
  #     (kanban/ andon/ doctrina/ docs/guias/) -- cierra los "enlaces muertos en un repo
  #     ajeno" (bloqueante de 1.0). Se excluye docs/decisions/ (los ADR son procedencia
  #     de Jidoka: apuntan a la fuente, no viven en el hijo).
  $muertos = @()
  foreach ($md in (Get-ChildItem -LiteralPath $tmp -Recurse -File -Filter *.md)) {
    $txt = Get-Content -LiteralPath $md.FullName -Raw
    $txt = [regex]::Replace($txt, 'https?://\S+', '')   # quita URLs: un link externo no es una ruta local
    foreach ($m in [regex]::Matches($txt, '(kanban|andon|doctrina|docs/guias)/[A-Za-z0-9_./-]+\.md')) {
      if (-not (Test-Path -LiteralPath (Join-Path $tmp $m.Value))) { $muertos += ("{0} -> {1}" -f $md.Name, $m.Value) }
    }
  }
  Check 'enlaces de metodo: ningun doc sembrado cita un doc de metodo ausente' ($muertos.Count -eq 0) (($muertos | Select-Object -Unique -First 5) -join ' | ')

  # 2. Commit inicial (un repo recien sembrado se commitea antes de que verificar mida).
  Push-Location $tmp
  git add -A 2>&1 | Out-Null
  git -c user.email='smoke@jidoka.local' -c user.name='smoke' -c commit.gpgsign=false commit -q -m 'sembrado inicial' 2>&1 | Out-Null
  Pop-Location

  # 3. Los self-tests SEMBRADOS deben pasar en el destino.
  foreach ($t in @('probar-gate', 'probar-hooks', 'probar-auditor', 'probar-disparos')) {
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
  $selloObj.sembrado_hashes.'tools/probar-hooks.ps1' = (Get-HashLF $hookChild)
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
  $jidokaAudHash = (Get-HashLF (Join-Path $PSScriptRoot 'auditar.ps1'))
  Check 'actualizar: el sello guarda el hash que Jidoka ENVIA (no el custom del hijo)' ($selloDespues.sembrado_hashes.'tools/auditar.ps1' -eq $jidokaAudHash) "el sello no guardo el hash de Jidoka"

  # 5c. Segunda corrida: la divergencia persiste hasta reconciliar; lo restaurado ya esta al dia.
  Run-PS $instalar -Destino $tmp -Actualizar | Out-Null
  $persiste = ((Get-Content $audChild -Raw) -match 'ajuste propio del hijo') -and (Test-Path "$audChild.jidoka-nuevo")
  Check 'actualizar (2a vez): la divergencia persiste, lo demas converge' $persiste "no fue idempotente"

  # 5c2. MIGRACION (cosecha #7, issue #86): un hijo "pre-1.17" -- sin los stubs que el
  # arranca nuevo inyecta y con sello sin arquetipo -- recibe en -Actualizar los stubs
  # comunes que le faltan ([MIGRA]) sin tocar la instancia existente; lo condicionado a
  # arquetipo NO se adivina (avisa). Con sello 1.17+ (producto registrado) SI se decide.
  Remove-Item (Join-Path $tmp 'product/PRODUCT_BRIEF.md') -Force
  Remove-Item (Join-Path $tmp 'product/infra.md') -Force
  Remove-Item (Join-Path $tmp 'CONTRIBUTING.md') -Force
  Remove-Item (Join-Path $tmp 'product/README.md') -Force
  $selloMig = Get-Content $selloPath -Raw | ConvertFrom-Json
  $selloMig.PSObject.Properties.Remove('producto')
  [System.IO.File]::WriteAllText($selloPath, ($selloMig | ConvertTo-Json -Depth 5), (New-Object System.Text.UTF8Encoding($false)))
  $outMig = Run-PS-Out $instalar -Destino $tmp -Actualizar
  $stubsMigraron = (Test-Path (Join-Path $tmp 'product/PRODUCT_BRIEF.md')) -and (Test-Path (Join-Path $tmp 'product/infra.md')) -and (Test-Path (Join-Path $tmp 'CONTRIBUTING.md'))
  Check 'migra: -Actualizar siembra los stubs comunes que el hijo no tenia ([MIGRA])' ($stubsMigraron -and ($outMig -match 'MIGRA')) "faltan stubs (brief/infra/CONTRIBUTING) o no reporto MIGRA"
  Check 'migra: la instancia existente NO se toca (HANDOFF con marca)' ((Get-Content $handoff -Raw) -match $marca) "se toco HANDOFF"
  Check 'migra: sello pre-1.17 (sin producto) NO adivina el stub del arquetipo y avisa' ((-not (Test-Path (Join-Path $tmp 'product/README.md'))) -and ($outMig -match 'pre-1\.17')) "sembro el stub de arquetipo sin sello, o no aviso"
  $selloMig2 = Get-Content $selloPath -Raw | ConvertFrom-Json
  $selloMig2 | Add-Member -NotePropertyName producto -NotePropertyValue 'grafo' -Force
  [System.IO.File]::WriteAllText($selloPath, ($selloMig2 | ConvertTo-Json -Depth 5), (New-Object System.Text.UTF8Encoding($false)))
  Run-PS $instalar -Destino $tmp -Actualizar | Out-Null
  Check 'migra: con sello 1.17+ (producto=grafo) siembra la semilla del QUE faltante' (Test-Path (Join-Path $tmp 'product/README.md')) "no sembro product/README.md"
  $selloTrasMigra = Get-Content $selloPath -Raw | ConvertFrom-Json
  Check 'migra: -Actualizar preserva el producto registrado en el sello' ($selloTrasMigra.producto -eq 'grafo') "el sello perdio producto (quedo '$($selloTrasMigra.producto)')"

  # 5d. ESTADO-MOTOR: el aviso de divergencia (nunca bloquea; exit 0 siempre).
  $em = Join-Path $tmp 'tools/estado-motor.ps1'
  Check 'instala: estado-motor.ps1 queda sembrado' (Test-Path $em) "no aparecio estado-motor.ps1"
  # Canal de subida (UP) sembrado: el helper + la guia para reportar lecciones a Jidoka.
  Check 'instala: reportar-leccion.ps1 queda sembrado (canal de subida)' (Test-Path (Join-Path $tmp 'tools/reportar-leccion.ps1')) "no aparecio reportar-leccion.ps1"
  Check 'instala: la guia de subida queda sembrada' (Test-Path (Join-Path $tmp 'docs/guias/reportar-leccion-a-jidoka.md')) "no aparecio la guia"
  $emOut1 = Run-PS-Out $em
  Check 'estado-motor: sin -Jidoka informa y no bloquea (exit 0)' ($LASTEXITCODE -eq 0) "exit $LASTEXITCODE"
  # Contra un Jidoka FALSO mas nuevo: debe avisar que difiere.
  $fakeJ = Join-Path $env:TEMP ("jidoka-fake-" + [guid]::NewGuid().ToString('N').Substring(0,6))
  New-Item -ItemType Directory -Path (Join-Path $fakeJ 'tools') -Force | Out-Null
  Set-Content -Path (Join-Path $fakeJ 'tools/version.txt') -Value '9.9.9-nuevo' -Encoding ASCII
  $emOut2 = Run-PS-Out $em -Jidoka $fakeJ
  Check 'estado-motor: contra un Jidoka mas nuevo, avisa que difiere' (($emOut2 -match '9\.9\.9-nuevo') -and ($emOut2 -match 'AVISO')) "no aviso divergencia"
  # Contra el Jidoka REAL (misma version del sello): al dia.
  $emOut3 = Run-PS-Out $em -Jidoka (Split-Path -Parent $PSScriptRoot)
  Check 'estado-motor: contra Jidoka real (misma version), estado OK' ($emOut3 -match '\[OK\]') "no dio el OK de version"
  Remove-Item $fakeJ -Recurse -Force -ErrorAction SilentlyContinue

  # 5e. -SELLAR: sella un hijo que convergio a mano, CLASIFICANDO pristina-vs-customizada
  # (ADR 0019). Customizo una pieza pristina, borro el sello, y sello de cero: la
  # customizada NO debe entrar en la semilla (asi -Actualizar la preservara); una pristina SI.
  $auditorChild = Join-Path $tmp 'tools/probar-auditor.ps1'
  Add-Content -Path $auditorChild -Value '# customizacion del hijo para -Sellar'
  Remove-Item $selloPath -Force
  Run-PS $instalar -Destino $tmp -Sellar | Out-Null
  Check 'sellar: re-crea el sello' (Test-Path $selloPath) "no se escribio el sello"
  $selloSel = Get-Content $selloPath -Raw | ConvertFrom-Json
  Check 'sellar: el sello queda en la version de Jidoka' ($selloSel.version -eq $verTxt) "version quedo $($selloSel.version)"
  Check 'sellar: NO registra una pieza customizada (se preservara)' (-not $selloSel.sembrado_hashes.'tools/probar-auditor.ps1') "registro la customizada"
  Check 'sellar: SI registra una pieza pristina' ([bool]$selloSel.sembrado_hashes.'tools/probar-gate.ps1') "no registro la pristina"
  # Tras -Sellar, -Actualizar debe PRESERVAR la customizada (child != seed=null -> DIVERGE).
  Run-PS $instalar -Destino $tmp -Actualizar | Out-Null
  Check 'sellar+actualizar: la pieza customizada se preserva (no se pisa)' ((Get-Content $auditorChild -Raw) -match 'customizacion del hijo para -Sellar') "se piso la customizada tras sellar"
  # estado-motor -Detallado: la ve DIVERGE por-hash (la version sola no la veria).
  $emDet = Run-PS-Out $em -Jidoka (Split-Path -Parent $PSScriptRoot) -Detallado
  Check 'estado-motor -Detallado: lista la pieza divergente por-hash' (($emDet -match 'probar-auditor') -and ($emDet -match 'DIVERGE')) "no listo la divergencia"

  # 5f. EOL-AGNOSTICO (ADR 0021): un hijo con working tree en LF debe reconciliar por
  # CONTENIDO, no por bytes. Sin el fix, hash(LF) != seed(CRLF) y TODO divergiria (el
  # defecto cazado al bajar a tracker-financiero). Instalo un hijo limpio, convierto su
  # arbol a LF, y -Actualizar NO debe reportar ninguna divergencia (mismo contenido).
  $tmpLF = Join-Path $env:TEMP ("jidoka-smokeLF-" + [guid]::NewGuid().ToString('N').Substring(0,8))
  try {
    Run-PS $instalar -Destino $tmpLF -Yes | Out-Null
    Get-ChildItem -LiteralPath $tmpLF -Recurse -File | ForEach-Object {
      $b = [System.IO.File]::ReadAllBytes($_.FullName)
      if ($b -contains 13) {
        $lf = New-Object System.Collections.Generic.List[byte]
        foreach ($x in $b) { if ($x -ne 13) { $lf.Add($x) } }
        [System.IO.File]::WriteAllBytes($_.FullName, $lf.ToArray())
      }
    }
    $outLF = Run-PS-Out $instalar -Destino $tmpLF -Actualizar
    Check 'eol-agnostico: un hijo LF reconcilia por contenido (0 divergencias)' (($outLF -notmatch '\[DIVERGE\]') -and ($outLF -match '\|\s*0 divergen')) "un hijo LF diverge por EOL: $outLF"
  }
  finally { Remove-Item $tmpLF -Recurse -Force -ErrorAction SilentlyContinue }

  # 5g. LISTA DE EXCLUSION (ADR 0022): el hijo declara piezas que NO quiere; el lazo no
  # las re-agrega. Simula el back-out recurrente de los labs. Agrego 'excluir' al sello,
  # borro la pieza, y -Actualizar NO debe re-agregarla (ni tocarla) + preserva la lista.
  $gateChild = Join-Path $tmp 'tools/probar-gate.ps1'
  $selloExc = Get-Content $selloPath -Raw | ConvertFrom-Json
  $selloExc | Add-Member -NotePropertyName excluir -NotePropertyValue @('tools/probar-gate.ps1') -Force
  [System.IO.File]::WriteAllText($selloPath, ($selloExc | ConvertTo-Json -Depth 5), (New-Object System.Text.UTF8Encoding($false)))
  Remove-Item $gateChild -Force
  $outExc = Run-PS-Out $instalar -Destino $tmp -Actualizar
  Check 'excluir: la pieza excluida NO se re-agrega' (-not (Test-Path $gateChild)) "se re-agrego una pieza excluida"
  Check 'excluir: -Actualizar la reporta como EXCLUIDA' ($outExc -match 'EXCLUIDA') "no reporto la exclusion"
  $selloTrasExc = Get-Content $selloPath -Raw | ConvertFrom-Json
  Check 'excluir: el sello preserva la lista de exclusion' (@($selloTrasExc.excluir) -contains 'tools/probar-gate.ps1') "se perdio la lista de exclusion"

  # 5h. BROWNFIELD (jidoka#36): instalar sobre un repo con una pieza de mecanica YA
  # customizada (preservada por no-clobber) NO debe registrar el hash del HIJO como
  # semilla -- si lo hiciera, un -Actualizar posterior veria hijo==semilla y PISARIA
  # la customizacion (perdida de datos). El sello de la instalacion limpia debe
  # CLASIFICAR igual que -Sellar: omitir la customizada, registrar la pristina.
  $tmpBf = Join-Path $env:TEMP ("jidoka-brownfield-" + [guid]::NewGuid().ToString('N').Substring(0,8))
  try {
    New-Item -ItemType Directory -Path (Join-Path $tmpBf 'tools') -Force | Out-Null
    $bfVerif = Join-Path $tmpBf 'tools/verificar.ps1'
    Set-Content -Path $bfVerif -Value '# verificar CUSTOMIZADO del hijo (brownfield)' -Encoding ASCII
    Run-PS $instalar -Destino $tmpBf -Arquetipo 'docs-as-code' -Yes | Out-Null
    Check 'brownfield: no-clobber preserva la pieza customizada' ((Get-Content $bfVerif -Raw) -match 'CUSTOMIZADO del hijo') "se piso la pieza customizada"
    $selloBf = Get-Content (Join-Path $tmpBf 'tools/jidoka-motor.json') -Raw | ConvertFrom-Json
    Check 'brownfield: el sello NO registra la pieza customizada (asi -Actualizar no la pisa)' (-not $selloBf.sembrado_hashes.'tools/verificar.ps1') "registro el hash del hijo como semilla"
    Check 'brownfield: el sello SI registra una pieza pristina recien sembrada' ([bool]$selloBf.sembrado_hashes.'tools/auditar.ps1') "no registro una pieza pristina"
  }
  finally { Remove-Item $tmpBf -Recurse -Force -ErrorAction SilentlyContinue }

  # 5i. FALSO-VERDE ANIDADO (R8, volver-muro): -Sellar contra un lab cuya maquinaria quedo
  # ANIDADA bajo un contenedor (jidoka/tools/... en vez de tools/ raiz) NO debe sellar a
  # ciegas. ANTES: resolvia mal la raiz, hallaba 0 piezas de motor, escribia un sello VACIO
  # (sembrado_hashes:{}) en un tools/ NUEVO en la raiz (segundo motor) y salia exit 0 --
  # falso-verde silencioso (aprueba sin mirar nada). AHORA: FALLA CERRADO (exit != 0) y no
  # escribe el sello ciego.
  $tmpNest = Join-Path $env:TEMP ("jidoka-anidado-" + [guid]::NewGuid().ToString('N').Substring(0,8))
  try {
    New-Item -ItemType Directory -Path (Join-Path $tmpNest 'jidoka/tools') -Force | Out-Null
    # la maquinaria vive ANIDADA (mal resuelta): hay motor bajo jidoka/tools/, nada en tools/ raiz.
    Copy-Item (Join-Path $PSScriptRoot 'verificar.ps1') (Join-Path $tmpNest 'jidoka/tools/verificar.ps1')
    Copy-Item (Join-Path $PSScriptRoot 'auditar.ps1')   (Join-Path $tmpNest 'jidoka/tools/auditar.ps1')
    $codeNest = Run-PS $instalar -Destino $tmpNest -Sellar
    Check 'anidado: -Sellar sobre maquinaria ANIDADA FALLA CERRADO (no exit 0 silencioso)' ($codeNest -ne 0) "exit $codeNest (sello a ciegas = falso-verde)"
    Check 'anidado: NO escribe un sello vacio en un tools/ raiz nuevo (segundo motor)' (-not (Test-Path (Join-Path $tmpNest 'tools/jidoka-motor.json'))) "escribio un sello a ciegas en la raiz"
  }
  finally { Remove-Item $tmpNest -Recurse -Force -ErrorAction SilentlyContinue }

  # 5j. APLANADO/NORMAL sigue verde: -Sellar contra un hijo con la maquinaria en tools/ raiz
  # SIGUE sellando (la cura no rompe el caso sano). Instalo limpio, borro el sello, y re-sello.
  $tmpFlat = Join-Path $env:TEMP ("jidoka-aplanado-" + [guid]::NewGuid().ToString('N').Substring(0,8))
  try {
    Run-PS $instalar -Destino $tmpFlat -Arquetipo 'docs-as-code' -Yes | Out-Null
    Remove-Item (Join-Path $tmpFlat 'tools/jidoka-motor.json') -Force
    $codeFlat = Run-PS $instalar -Destino $tmpFlat -Sellar
    Check 'aplanado: -Sellar sobre maquinaria en tools/ raiz sigue sellando (exit 0)' ($codeFlat -eq 0) "exit $codeFlat"
    $selloFlat = Join-Path $tmpFlat 'tools/jidoka-motor.json'
    $registroOk = $false
    if (Test-Path $selloFlat) { $registroOk = ((Get-Content $selloFlat -Raw | ConvertFrom-Json).sembrado_hashes.PSObject.Properties | Measure-Object).Count -gt 0 }
    Check 'aplanado: el sello re-creado registra piezas de motor (no vacio)' $registroOk "sello vacio o ausente"
  }
  finally { Remove-Item $tmpFlat -Recurse -Force -ErrorAction SilentlyContinue }

  # 6. Segundo arquetipo: code-first siembra DISTINTO (brief, no grafo) y su gate pasa.
  $tmp2 = Join-Path $env:TEMP ("jidoka-smoke2-" + [guid]::NewGuid().ToString('N').Substring(0,8))
  try {
    Run-PS $instalar -Destino $tmp2 -Arquetipo 'code-first' -Yes | Out-Null
    # Cosecha #7 (issue #86): el brief es stub comun en product/ (el arranca lo inyecta
    # para todo arquetipo); la raiz queda limpia y el grafo sigue siendo solo de docs-as-code.
    $brief = (Test-Path (Join-Path $tmp2 'product/PRODUCT_BRIEF.md'))
    $briefRaiz = (Test-Path (Join-Path $tmp2 'PRODUCT_BRIEF.md'))
    $grafo = (Test-Path (Join-Path $tmp2 'product/README.md'))
    Check 'code-first: siembra product/PRODUCT_BRIEF (no en raiz) y NO el grafo de notas' ($brief -and -not $briefRaiz -and -not $grafo) "brief=$brief raiz=$briefRaiz grafo=$grafo"
    $leyOk = $false
    try { Get-Content (Join-Path $tmp2 'tools/blast-radius.json') -Raw | ConvertFrom-Json | Out-Null; $leyOk = $true } catch {}
    Check 'code-first: su ley parsea' $leyOk "la ley code-first no parsea"
    # jidoka#38: code-first EXCLUYE probar-gate.ps1 y andon.yml (su verificar customizado
    # code-first no los pasa). NO se siembran, y el sello los anota en 'excluir' para que
    # un -Actualizar posterior no los re-agregue.
    Check 'code-first: NO siembra tools/probar-gate.ps1 (excluida por el arquetipo)' (-not (Test-Path (Join-Path $tmp2 'tools/probar-gate.ps1'))) "se sembro una pieza excluida"
    Check 'code-first: NO siembra .github/workflows/andon.yml (excluida por el arquetipo)' (-not (Test-Path (Join-Path $tmp2 '.github/workflows/andon.yml'))) "se sembro una pieza excluida"
    $selloCf = Get-Content (Join-Path $tmp2 'tools/jidoka-motor.json') -Raw | ConvertFrom-Json
    $excCf = @($selloCf.excluir)
    Check 'code-first: el sello anota AMBAS exclusiones en excluir' (($excCf -contains 'tools/probar-gate.ps1') -and ($excCf -contains '.github/workflows/andon.yml')) "excluir = $($excCf -join ', ')"
    Check 'code-first: el sello NO registra una pieza excluida en sembrado_hashes' (-not $selloCf.sembrado_hashes.'tools/probar-gate.ps1') "registro una excluida como semilla"

    Push-Location $tmp2
    git add -A 2>&1 | Out-Null
    git -c user.email='smoke@jidoka.local' -c user.name='smoke' -c commit.gpgsign=false commit -q -m 'sembrado' 2>&1 | Out-Null
    Pop-Location

    # Costura .local: verificar dot-sourcea tools/verificar.local.ps1 si existe.
    # (repo recien commiteado y limpio: aisla el efecto de la extension del git-state)
    $vLimpio = Run-PS (Join-Path $tmp2 'tools/verificar.ps1')
    Check '.local: sin extension, verificar corre limpio (exit 0)' ($vLimpio -eq 0) "exit $vLimpio"
    Set-Content -Path (Join-Path $tmp2 'tools/verificar.local.ps1') -Value 'Block "check local de prueba"' -Encoding ASCII
    $vConLocal = Run-PS (Join-Path $tmp2 'tools/verificar.ps1')
    Check '.local: la extension se dot-sourcea y su Block cuenta (exit 1)' ($vConLocal -eq 1) "exit $vConLocal (esperaba 1)"
    Remove-Item (Join-Path $tmp2 'tools/verificar.local.ps1') -Force
    $vSinLocal = Run-PS (Join-Path $tmp2 'tools/verificar.ps1')
    Check '.local: al quitar la extension, verificar vuelve a exit 0' ($vSinLocal -eq 0) "exit $vSinLocal"
  }
  finally { Remove-Item $tmp2 -Recurse -Force -ErrorAction SilentlyContinue }

  # 7. Arquetipo por default con -Yes (sin -Arquetipo): desatendido cae a docs-as-code
  #    (grafo), no pregunta ni falla. El prompt interactivo se prueba a mano (Read-Host).
  $tmp3 = Join-Path $env:TEMP ("jidoka-smoke3-" + [guid]::NewGuid().ToString('N').Substring(0,8))
  try {
    Run-PS $instalar -Destino $tmp3 -Yes | Out-Null
    $g3 = (Test-Path (Join-Path $tmp3 'product/README.md'))
    $b3raiz = (Test-Path (Join-Path $tmp3 'PRODUCT_BRIEF.md'))
    Check 'default -Yes sin -Arquetipo: cae a docs-as-code (grafo; raiz sin brief)' ($g3 -and -not $b3raiz) "grafo=$g3 briefRaiz=$b3raiz"
  }
  finally { Remove-Item $tmp3 -Recurse -Force -ErrorAction SilentlyContinue }
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
