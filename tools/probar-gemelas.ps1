#Requires -Version 5
# probar-gemelas.ps1 - self-test anti-drift de las copias gemelas (sprint 26).
# La duplicacion es DOCTRINA en este repo: cada gate/hook corre standalone, sin
# dot-source (los hooks reciben stdin y no pueden depender de tools/). El precio:
# una correccion en una copia puede olvidar a las demas -- y entonces la vista
# mide distinto que el gate (el verde vuelve a mentir). Este self-test convierte
# la promesa "byte-fiel" de los comentarios en contrato verificado: extrae cada
# funcion gemela declarada abajo y FALLA si las copias divergen.
#
# Normalizacion (tolera formato, atrapa semantica): se quitan lineas-comentario
# y blancos, y se ignora todo whitespace y ';' (un one-liner vs tres lineas es
# formato, no drift). Lo que SI truena: nombres de parametros/variables, claves,
# operadores, textos -- exactamente lo que hizo divergir a Clase-Display.
#
# Frontera confesada (NO cubierto): los bloques INLINE gemelos (triple fallback
# de rango git en verificar/estado-ligas, parser del ROADMAP como bloque en
# verificar/expirar, patron leer-de-la-BASE en andon.yml) no son funciones
# nombradas extraibles; su drift lo vigilan los self-tests funcionales de cada
# gate. Variantes LEGITIMAS que no se comparan: Get-Secciones de probar-adrs
# (usa Fold, dominio ADR) y Write-GitFailWarning (su texto nombra a cada hook).
# Archivo ASCII a proposito, PS 5.1.
#   exit 0 = todas las gemelas identicas; exit 1 = drift detectado.

$raiz = Split-Path -Parent $PSScriptRoot
$script:fallos = 0

function Check($nombre, $cond, $detalle) {
  if ($cond) { Write-Host "  [PASA]  $nombre" -ForegroundColor Green }
  else { Write-Host "  [FALLA] $nombre ($detalle)" -ForegroundColor Red; $script:fallos++ }
}

# Extrae el cuerpo de 'function <nombre>' de un .ps1 contando llaves desde su
# primera linea. Devuelve $null si la funcion no existe (eso tambien es drift:
# una copia renombrada o borrada). Las lineas-comentario se quitan ANTES de
# contar llaves (un '#' con llave desbalanceada no debe romper el conteo).
function Get-CuerpoFuncion($pathAbs, $nombre) {
  if (-not (Test-Path -LiteralPath $pathAbs)) { return $null }
  $lines = [System.IO.File]::ReadAllLines($pathAbs)
  $inicio = -1
  for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match ('^\s*function\s+' + [regex]::Escape($nombre) + '\b')) { $inicio = $i; break }
  }
  if ($inicio -lt 0) { return $null }
  $depth = 0; $abierto = $false; $cuerpo = @()
  for ($i = $inicio; $i -lt $lines.Count; $i++) {
    $ln = $lines[$i]
    if ($ln.Trim().StartsWith('#')) { continue }
    $cuerpo += $ln
    foreach ($ch in $ln.ToCharArray()) {
      if ($ch -eq '{') { $depth++; $abierto = $true }
      elseif ($ch -eq '}') { $depth-- }
    }
    if ($abierto -and $depth -le 0) { break }
  }
  if (-not $abierto -or $depth -gt 0) { return $null }
  return ,$cuerpo
}

# Normaliza el cuerpo para comparar: fuera blancos, fuera whitespace y ';' --
# pero SOLO FUERA de literales de string (hallazgo del review del sprint 26: quitar
# whitespace dentro de un literal colapsaria 'a b' y 'ab' a la misma huella, un
# falso PASA). Tokenizador minimo de comillas PS: '...' y "..." conservan su
# contenido intacto; el whitespace estructural de afuera es el que no importa.
function Get-Huella($cuerpo) {
  $blob = ($cuerpo | Where-Object { $_.Trim() -ne '' }) -join "`n"
  $sb = New-Object System.Text.StringBuilder
  $enComilla = [char]0   # 0 = fuera; o la comilla que abrio (' o ")
  foreach ($ch in $blob.ToCharArray()) {
    if ($enComilla -ne [char]0) {
      [void]$sb.Append($ch)
      if ($ch -eq $enComilla) { $enComilla = [char]0 }
      continue
    }
    if ($ch -eq [char]39 -or $ch -eq [char]34) { $enComilla = $ch; [void]$sb.Append($ch); continue }
    if ([char]::IsWhiteSpace($ch) -or $ch -eq ';') { continue }
    [void]$sb.Append($ch)
  }
  return $sb.ToString()
}

# El ledger de gemelas: cada grupo DEBE ser identico (modulo formato) en todos
# sus miembros. Agregar una copia nueva a un script = agregarla AQUI.
$GRUPOS = @(
  @{ fn = 'Test-Pattern';    en = @('tools/verificar.ps1','tools/estado-ligas.ps1','tools/estado-gobierno.ps1','tools/bandeja.ps1','.claude/hooks/andon-stop.ps1','.claude/hooks/review-stop.ps1','.claude/hooks/gemba-stop.ps1','.claude/hooks/validador-stop.ps1') }
  @{ fn = 'Match-Any';       en = @('tools/verificar.ps1','tools/estado-ligas.ps1','.claude/hooks/andon-stop.ps1') }
  @{ fn = 'Normaliza';       en = @('tools/estado-docs.ps1','tools/bandeja.ps1','tools/estado-gobierno.ps1') }
  @{ fn = 'Get-Secciones';   en = @('tools/estado-docs.ps1','tools/bandeja.ps1','tools/estado-gobierno.ps1') }
  @{ fn = 'Test-NoVacio';    en = @('tools/rutear.ps1','tools/estado-gobierno.ps1','tools/bandeja.ps1') }
  @{ fn = 'Get-GatesDeArea'; en = @('tools/rutear.ps1','tools/estado-gobierno.ps1') }
  @{ fn = 'Test-EnLaLey';    en = @('tools/bandeja.ps1','tools/estado-gobierno.ps1') }
  @{ fn = 'Clase-Display';   en = @('tools/estado-flujo.ps1','tools/expirar.ps1') }
  @{ fn = 'Fin';             en = @('tools/estado-flujo.ps1','tools/expirar.ps1') }
  @{ fn = 'Fail';            en = @('tools/verificar.ps1','tools/estado-ligas.ps1') }
  @{ fn = 'Fail';            en = @('tools/anti-pii.ps1','tools/auditar.ps1') }   # variante sin Pop-Location (no hacen Push)
)

Write-Host "== Gemelas sin drift (las copias standalone deben seguir identicas) =="

foreach ($g in $GRUPOS) {
  $fn = $g.fn
  $canonicoRel = $g.en[0]
  $canonico = Get-CuerpoFuncion (Join-Path $raiz $canonicoRel) $fn
  if ($null -eq $canonico) {
    Check "$fn en $canonicoRel" $false 'no pude extraer la funcion canonica: renombrada, borrada o llaves desbalanceadas'
    continue
  }
  $huellaCanon = Get-Huella $canonico
  for ($i = 1; $i -lt $g.en.Count; $i++) {
    $rel = $g.en[$i]
    $copia = Get-CuerpoFuncion (Join-Path $raiz $rel) $fn
    if ($null -eq $copia) {
      Check "$fn : $rel == $canonicoRel" $false 'la copia no existe o no se pudo extraer'
      continue
    }
    $ok = ((Get-Huella $copia) -eq $huellaCanon)
    Check "$fn : $rel == $canonicoRel" $ok 'las copias divergieron: alinea la copia con la canonica (la primera del grupo)'
    if (-not $ok) {
      Write-Host "          canonica ($canonicoRel):" -ForegroundColor DarkGray
      foreach ($l in $canonico) { if ($l.Trim() -ne '') { Write-Host "            | $($l.Trim())" -ForegroundColor DarkGray } }
      Write-Host "          copia ($rel):" -ForegroundColor DarkGray
      foreach ($l in $copia) { if ($l.Trim() -ne '') { Write-Host "            | $($l.Trim())" -ForegroundColor DarkGray } }
    }
  }
}

Write-Host ""
if ($script:fallos -gt 0) {
  Write-Host "== $($script:fallos) drift(s) entre gemelas. La vista y el gate ya no miden igual: alinea las copias. ==" -ForegroundColor Red
  exit 1
}
Write-Host "== Gemelas identicas: las copias standalone siguen siendo la misma regla. ==" -ForegroundColor Green
exit 0
