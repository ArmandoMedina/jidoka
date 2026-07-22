#Requires -Version 5
# probar-app.ps1 - lint del cascaron de la app de la tuberia (app/).
# La app es un cascaron Tauri v2 cuya interfaz ES la maqueta. En R2 no hay compilador
# barato que corra en el CI (Rust no vive ahi), asi que este lint verifica los CONTRATOS
# que un test SI puede afirmar sin cargo: (a) la UI es copia byte-fiel de la spec congelada
# (la vara del Gemba de fidelidad), (b) la DECISION de que app/ es Jidoka-only sigue siendo
# cierta -- si alguien la mete al manifiesto de siembra, esto lo caza (ADR 0048, migrado del
# invariante de probar-extension.ps1), (c) la config Tauri parsea y apunta a la UI, y (d) las
# piezas del cascaron (Cargo.toml, main.rs) existen.
# NO invoca cargo: el CI no tiene Rust; el build local es la evidencia del .exe.
# Jidoka-only (como probar-extension): NO se siembra. PS 5.1, ASCII a proposito.

$ErrorActionPreference = 'Stop'
$raiz = Split-Path -Parent $PSScriptRoot
if (-not $raiz) { $raiz = (Get-Location).Path }

$script:pass = 0; $script:fail = 0
function Ok($m) { Write-Host "  [PASA]  $m"; $script:pass++ }
function No($m) { Write-Host "  [FALLA] $m" -ForegroundColor Red; $script:fail++ }

Write-Host "== App de la tuberia: cascaron fiel (app/) =="

$dir = Join-Path $raiz 'app'
$uiPath = Join-Path $dir 'ui/index.html'
$specPath = Join-Path $raiz 'docs/analisis/maqueta-tuberia-202607.html'

# (a) FIDELIDAD -- R3: el assert byte-identico YA NO aplica (la mitad UI reemplazo el bloque
# de datos por invoke() al motor, decision de diseno 3). Se reemplaza por PARIDAD ESTRUCTURAL
# contra la spec congelada + hash del <style> byte-identico (el CSS no tenia razon de cambiar;
# los 2 botones nuevos usan clases inline, no tocan el <style>). La vara del Gemba de fidelidad
# ya la aprobo el cliente ("Si es fiel... abre y se ve como me gusto", 2026-07-21).
function Get-StyleBlock($html) {
  $m = [regex]::Match($html, '(?s)<style>.*?</style>')
  if ($m.Success) { return $m.Value } else { return $null }
}
if (-not (Test-Path -LiteralPath $uiPath)) {
  No "no existe app/ui/index.html (la interfaz de la app)"
}
elseif (-not (Test-Path -LiteralPath $specPath)) {
  No "no existe la spec congelada docs/analisis/maqueta-tuberia-202607.html (la vara de fidelidad)"
}
else {
  Ok "existe app/ui/index.html (la interfaz)"
  $uiText = Get-Content -LiteralPath $uiPath -Raw
  $specText = Get-Content -LiteralPath $specPath -Raw

  # Paridad estructural: los IDs de tabs, #ovl/#wiz, las variables CSS de la paleta y las
  # funciones clave del JS de la maqueta siguen presentes en la UI (grep textual).
  $marcadores = @(
    @('id="tuberia"', 'el tab #tuberia'),
    @('id="bandeja"', 'el tab #bandeja'),
    @('id="flujos"', 'el tab #flujos'),
    @('id="huecos"', 'el tab #huecos'),
    @('id="ovl"', 'el overlay #ovl (wizard modal)'),
    @('id="wiz"', 'el contenedor #wiz'),
    @('--bg:', 'la variable CSS --bg (paleta)'),
    @('--violet:', 'la variable CSS --violet (paleta)'),
    @('function wizStart', 'la funcion wizStart (wizards)'),
    @('function tourStart', 'la funcion tourStart (tour)'),
    @('function rootCheck', 'la funcion rootCheck (modo avanzado)'),
    @('function wizRender', 'la funcion wizRender (wizards)')
  )
  foreach ($mk in $marcadores) {
    if ($uiText -match [regex]::Escape($mk[0])) { Ok "paridad estructural: presente $($mk[1])" }
    else { No "paridad estructural: FALTA $($mk[1]) ('$($mk[0])') en app/ui/index.html" }
  }

  # Los sentinelas que marcan el bloque de datos reemplazado (mitad UI R3).
  if ($uiText -match 'JIDOKA:DATOS-INICIO' -and $uiText -match 'JIDOKA:DATOS-FIN') {
    Ok "sentinelas JIDOKA:DATOS-INICIO/FIN presentes (bloque de datos cableado a invoke)"
  } else {
    No "faltan los sentinelas JIDOKA:DATOS-INICIO/FIN (el bloque de datos debe estar marcado)"
  }

  # R5-UI: la contrasena 'GARANTIA-NULA' YA NO existe (el modo avanzado compara contra el
  # NOMBRE DEL REPO, patron GitHub, ADR 0047). Si reaparece, alguien revirtio el cableado.
  if ($uiText -match 'GARANTIA-NULA') {
    No "'GARANTIA-NULA' sigue en app/ui/index.html: el modo avanzado debe comparar contra el nombre del repo (R5-UI)"
  } else {
    Ok "'GARANTIA-NULA' ya no aparece (el modo avanzado teclea el nombre del repo, R5-UI)"
  }

  # R4/R5-UI: el JS invoca los dos motores de escritura (parametrizar y override_accion).
  if ($uiText -match "invoke\('parametrizar'" -or $uiText -match "invoke\(`"parametrizar`"") {
    Ok "el JS invoca 'parametrizar' (R4-UI: el formulario de alta escribe de verdad)"
  } else {
    No "el JS NO invoca 'parametrizar' (R4-UI: el formulario de alta no escribiria)"
  }
  if ($uiText -match "invoke\('override_accion'" -or $uiText -match "invoke\(`"override_accion`"") {
    Ok "el JS invoca 'override_accion' (R5-UI: el modo avanzado reclasifica/firma/candado de verdad)"
  } else {
    No "el JS NO invoca 'override_accion' (R5-UI: el modo avanzado no escribiria)"
  }

  # El <style> byte-identico al de la spec (el CSS no cambio; los botones nuevos son inline).
  $sUi = Get-StyleBlock $uiText
  $sSpec = Get-StyleBlock $specText
  if (-not $sUi) { No "no encuentro el bloque <style> en app/ui/index.html" }
  elseif (-not $sSpec) { No "no encuentro el bloque <style> en la spec congelada" }
  else {
    $sha = New-Object System.Security.Cryptography.SHA256Managed
    $enc = New-Object System.Text.UTF8Encoding($false)
    $hUiStyle = [BitConverter]::ToString($sha.ComputeHash($enc.GetBytes($sUi))).Replace('-', '')
    $hSpecStyle = [BitConverter]::ToString($sha.ComputeHash($enc.GetBytes($sSpec))).Replace('-', '')
    if ($hUiStyle -eq $hSpecStyle) {
      Ok "el <style> de app/ui/index.html es byte-identico al de la spec (CSS intacto, SHA256 $hUiStyle)"
    } else {
      No "el <style> de app/ui/index.html DIVERGE del de la spec (UI $hUiStyle vs spec $hSpecStyle): el CSS se toco"
    }
  }
}

# (c) La config Tauri parsea como JSON y su frontendDist apunta a la UI.
$confPath = Join-Path $dir 'src-tauri/tauri.conf.json'
if (-not (Test-Path -LiteralPath $confPath)) {
  No "no existe app/src-tauri/tauri.conf.json (la config del cascaron)"
}
else {
  Ok "existe app/src-tauri/tauri.conf.json"
  $conf = $null
  try { $conf = Get-Content -LiteralPath $confPath -Raw | ConvertFrom-Json; Ok "la config Tauri es JSON valido" }
  catch { No "app/src-tauri/tauri.conf.json no es JSON valido: $($_.Exception.Message)" }
  if ($conf) {
    $fd = "$($conf.build.frontendDist)"
    if ($fd -match 'ui') { Ok "frontendDist apunta a la UI ($fd)" }
    else { No "frontendDist ('$fd') no apunta a la UI (la app no serviria la maqueta)" }
    # withGlobalTauri: sin bundler, el JS usa window.__TAURI__.core.invoke (R3).
    if ($conf.app -and $conf.app.withGlobalTauri -eq $true) {
      Ok "app.withGlobalTauri = true (el JS invoca via window.__TAURI__.core.invoke)"
    } else {
      No "app.withGlobalTauri no es true (la mitad UI no podria invocar cargar_datos)"
    }
  }
}

# (d) Las piezas del cascaron Rust existen.
$cargoPath = Join-Path $dir 'src-tauri/Cargo.toml'
$mainPath = Join-Path $dir 'src-tauri/src/main.rs'
if (Test-Path -LiteralPath $cargoPath) { Ok "existe app/src-tauri/Cargo.toml" }
else { No "no existe app/src-tauri/Cargo.toml (el cascaron no compilaria)" }
if (Test-Path -LiteralPath $mainPath) { Ok "existe app/src-tauri/src/main.rs" }
else { No "no existe app/src-tauri/src/main.rs (falta el punto de entrada)" }

# R4/R5-UI: lib.rs registra los dos comandos nuevos de escritura (grep textual del handler).
$libPath = Join-Path $dir 'src-tauri/src/lib.rs'
if (-not (Test-Path -LiteralPath $libPath)) {
  No "no existe app/src-tauri/src/lib.rs (falta el puente Rust)"
} else {
  $libText = Get-Content -LiteralPath $libPath -Raw
  # Definidos como #[tauri::command] fn <nombre> Y registrados en generate_handler!.
  $regHandler = [regex]::Match($libText, '(?s)generate_handler!\s*\[(.*?)\]')
  $handlerBody = if ($regHandler.Success) { $regHandler.Groups[1].Value } else { '' }
  foreach ($cmd in @('parametrizar', 'override_accion')) {
    $definido = ($libText -match "fn\s+$cmd\s*\(")
    $registrado = ($handlerBody -match "\b$cmd\b")
    if ($definido -and $registrado) {
      Ok "lib.rs define y registra el comando '$cmd' (R4/R5-UI: el puente de escritura existe)"
    } else {
      No "lib.rs NO $((if(-not $definido){'define'}else{'registra'})) el comando '$cmd' (falta en el handler)"
    }
  }
}

# (b) LA DECISION COMO INVARIANTE (ADR 0048): app/ es Jidoka-only. Es la cara de Jidoka,
# no motor generico que se propaga a los hijos. Si alguien la agrega al manifiesto de
# siembra sin cambiar la decision, esto lo caza (migrado del invariante de la extension).
$sembradoPath = Join-Path $raiz 'kit/.jidoka/instalar/manifiesto.json'
if (Test-Path -LiteralPath $sembradoPath) {
  $sembrado = Get-Content -LiteralPath $sembradoPath -Raw
  if ($sembrado -match '"app/') {
    No "app/ aparece en el manifiesto de siembra: la decision (ADR 0048) dice Jidoka-only. Si cambio, cambia el ADR primero"
  } else {
    Ok "app/ NO se siembra a los hijos (Jidoka-only, ADR 0048)"
  }
}

# ----- R3-motor: el contrato de datos app<->motor (tools/tuberia-datos.ps1). -----
# La mitad UI (app.js con invoke) lee esta foto al abrir. El test afirma lo que un test SI
# puede: la foto corre sobre el repo real, parsea, trae sus 7 claves-datos, >=37 piezas, y
# el stdout es UTF-8 SIN BOM (el JS que lo parsea no tolera un BOM al frente).
$datosScript = Join-Path $raiz 'tools/tuberia-datos.ps1'
if (-not (Test-Path -LiteralPath $datosScript)) {
  No "no existe tools/tuberia-datos.ps1 (el consolidador de datos app<->motor)"
}
else {
  Ok "existe tools/tuberia-datos.ps1 (el contrato de datos app<->motor)"
  # Captura EXACTA como la del puente Rust: Process con pipe, leyendo los BYTES CRUDOS del
  # stdout -- SIN forzar StandardOutputEncoding. lib.rs lee los bytes tal cual y hace
  # from_utf8_lossy; forzar UTF8 aqui enmascararia el bug de encoding (sin consola, PS 5.1
  # emite su stdout en CP437: el '->' U+2192 se vuelve el byte 0x1A, un caracter de control).
  $psi = New-Object System.Diagnostics.ProcessStartInfo
  $psi.FileName = 'powershell'
  $psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$datosScript`""
  $psi.RedirectStandardOutput = $true
  $psi.UseShellExecute = $false
  $psi.CreateNoWindow = $true
  $pd = [System.Diagnostics.Process]::Start($psi)
  $ms = New-Object System.IO.MemoryStream
  $pd.StandardOutput.BaseStream.CopyTo($ms)
  $pd.WaitForExit()
  $datosBytes = $ms.ToArray()
  $datosExit = $pd.ExitCode
  # UTF-8 lossy: identico a String::from_utf8_lossy de Rust (byte malo -> U+FFFD).
  $datosTxt = [System.Text.Encoding]::UTF8.GetString($datosBytes)

  if ($datosExit -eq 0) { Ok "tuberia-datos.ps1 corre sobre el repo real (exit 0)" } else { No "tuberia-datos.ps1: esperaba exit 0, fue $datosExit" }
  if ($datosBytes.Length -ge 1 -and $datosBytes[0] -ne 0xEF) { Ok "tuberia-datos stdout sin BOM (el JS que lo parsea no tolera BOM)" } else { No "tuberia-datos: el stdout empieza con BOM (0xEF)" }
  # LA asercion que replica a JSON.parse de JS: ningun caracter de control (<0x20 salvo TAB/LF/CR)
  # dentro del stdout -- exactamente lo que rompia la app ("Bad control character in string literal").
  $ctrl = $null
  foreach ($ch in $datosTxt.ToCharArray()) { $cc = [int][char]$ch; if ($cc -lt 32 -and $cc -ne 9 -and $cc -ne 10 -and $cc -ne 13) { $ctrl = $cc; break } }
  if ($null -eq $ctrl) { Ok "tuberia-datos stdout SIN caracteres de control (JSON.parse de JS lo aceptaria)" } else { No ("tuberia-datos stdout trae un caracter de control (0x{0:X2}): JSON.parse de JS lo rechaza (Bad control character)" -f $ctrl) }
  # Los acentos y flechas sobreviven el viaje PS->Rust: ningun replacement char U+FFFD.
  if ($datosTxt.IndexOf([char]0xFFFD) -lt 0) { Ok "tuberia-datos stdout sin replacement chars (acentos y flechas intactos)" } else { No "tuberia-datos stdout trae U+FFFD: un acento/flecha se corrompio en el encoding" }
  $foto = $null
  try { $foto = $datosTxt | ConvertFrom-Json } catch { }
  if ($foto) {
    Ok "la foto consolidada parsea como JSON"
    $claves = @('version', 'repo', 'generado', 'piezas', 'aristas', 'regimenes', 'bandeja', 'ritual', 'areas')
    $faltan = @($claves | Where-Object { -not $foto.PSObject.Properties[$_] })
    if ($faltan.Count -eq 0) { Ok "la foto trae sus claves raiz (version/repo/generado/piezas/aristas/regimenes/bandeja/ritual/areas)" } else { No "la foto pierde clave(s) raiz: $($faltan -join ', ')" }
    if (@($foto.piezas).Count -ge 37) { Ok "la foto trae >=37 piezas (censo: $(@($foto.piezas).Count))" } else { No "la foto trae solo $(@($foto.piezas).Count) piezas (esperaba >=37)" }
    # --- R1: el censo se DERIVA de git ls-files (nada invisible) + convencion por carpeta. ---
    Push-Location $raiz
    $gitCount = @(@(git -c core.quotepath=false ls-files) + @(git -c core.quotepath=false ls-files --others --exclude-standard) | Where-Object { $_ } | Sort-Object -Unique).Count
    Pop-Location
    $pzCount = @($foto.piezas).Count
    # Tolerancia a churn menor: tuberia-datos y este test corren 'git ls-files' en momentos
    # distintos; un archivo creado/borrado entremedio (hook, IDE, build concurrente) no debe
    # dar falso rojo. Un delta grande SI es perdida real de piezas.
    $delta = [Math]::Abs($pzCount - $gitCount)
    if ($delta -eq 0) { Ok "completitud: 1 pieza por archivo de git ls-files ($pzCount) -- nada invisible" }
    elseif ($delta -le 3) { Ok "completitud: piezas ($pzCount) ~= git ls-files ($gitCount), delta $delta tolerado (churn del arbol)" }
    else { No "completitud: la foto trae $pzCount piezas pero git ls-files ve $gitCount (delta ${delta}: algo queda invisible o de mas)" }
    # un archivo conocido cae en su tipo bonito (Asientos)
    $agente = @($foto.piezas | Where-Object { $_.id -eq '.claude/agents/explorador.md' })
    if ($agente.Count -eq 1 -and $agente[0].tipo -like '*Asientos*') { Ok "tipo bonito: .claude/agents/explorador.md cae en Asientos" }
    else { No "tipo bonito: .claude/agents/explorador.md no cayo en Asientos ($($agente.Count) match)" }
    # catch-all: los sprints caen enteros en el cajon 'Sprints'
    $sprints = @($foto.piezas | Where-Object { $_.id -like 'docs/sprints/*' })
    $sprintsOk = @($sprints | Where-Object { $_.tipo -eq 'Sprints' })
    if ($sprints.Count -gt 0 -and $sprintsOk.Count -eq $sprints.Count) { Ok "catch-all: los $($sprints.Count) de docs/sprints/ caen en el cajon Sprints" }
    else { No "catch-all: docs/sprints no cayo entero en Sprints ($($sprintsOk.Count)/$($sprints.Count))" }
    # filtro del motor: ningun probar-* aparece como 'El motor'
    $probarEnMotor = @($foto.piezas | Where-Object { $_.tipo -like '*El motor*' -and (Split-Path $_.id -Leaf) -like 'probar-*' })
    if ($probarEnMotor.Count -eq 0) { Ok "filtro del motor: ningun probar-* aparece en El motor" }
    else { No "filtro del motor: $($probarEnMotor.Count) probar-* colados en El motor" }
    # areas: objetos con nombre (no solo strings) y al menos uno con doc_bloquea o doc_avisa
    $areasArr = @($foto.areas)
    $areasConNombre = @($areasArr | Where-Object { $_.PSObject.Properties['nombre'] -and "$($_.nombre)" -ne '' })
    if ($areasConNombre.Count -gt 0) {
      Ok "areas son objetos con campo nombre ($($areasConNombre.Count) areas)"
    } else {
      No "areas no son objetos con campo nombre (esperaba objetos {nombre,...})"
    }
    $areasConDoc = @($areasArr | Where-Object {
      ($_.PSObject.Properties['doc_bloquea'] -and @($_.doc_bloquea).Count -gt 0) -or
      ($_.PSObject.Properties['doc_avisa']   -and @($_.doc_avisa).Count   -gt 0)
    })
    if ($areasConDoc.Count -gt 0) {
      Ok "al menos un area trae doc_bloquea o doc_avisa ($($areasConDoc.Count) areas con docs)"
    } else {
      No "ninguna area trae doc_bloquea ni doc_avisa (esperaba al menos una)"
    }
  }
  else { No "la foto consolidada no parsea como JSON" }
}

Write-Host ""
if ($script:fail -gt 0) {
  Write-Host "== App INCOMPLETA: $($script:fail) fallo(s), $($script:pass) ok. ==" -ForegroundColor Red
  exit 1
}
Write-Host "== App sana: $($script:pass) verificaciones verdes. =="
exit 0
