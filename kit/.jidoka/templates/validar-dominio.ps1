#Requires -Version 5
# validar-dominio.ps1 - TEMPLATE del MOTOR DETERMINISTA de un gate de validacion por
# medicion (ADR 0028, disparo evidencia-no-palabra variante medicion). Copialo a
# tools/validar-<tu-dominio>.ps1 y llena la funcion Recalcular con TU formula.
#
# CONTRATO (lo que el gate validador-stop y el metodo esperan de este motor):
#   - Lee los golden-masters (fixtures capturados del sistema/oraculo real).
#   - RECALCULA el artefacto con la formula reconstruida. El calculo lo hace ESTE motor,
#     NUNCA el LLM: por eso es determinista y versionado.
#   - Emite una tabla entrada -> obtenido -> esperado (una fila por caso/celda).
#   - exit 0 si TODO cuadra dentro de la tolerancia; exit 1 si algo no.
#   - Guarda la tabla en qa_runs/validador-<fecha>/ y FORZALA al indice (git add -f):
#     qa_runs/ suele estar gitignoreado y el gate solo cuenta la evidencia que git rastrea.
#   - Si los fixtures son CONFIDENCIALES (PII): commitea la salida SANEADA (sin los datos
#     sensibles), no los fixtures. El gate corre LOCAL (Stop), no en CI.
#
# Uso:  ./tools/validar-<dominio>.ps1 [-FixturesDir <ruta>] [-OutDir <ruta>]
# Nota: ASCII a proposito, PS 5.1.

param(
  [string]$FixturesDir = 'evidencia/oraculo',        # <-- donde viven tus golden-masters
  [string]$OutDir      = "qa_runs/validador-$([DateTime]::Now.ToString('yyyyMMdd-HHmmss'))",
  [double]$Tolerancia  = 0.01                          # <-- +/- 1 centavo, ajusta a tu dominio
)

# --- 1. TU FORMULA (rellena esto). Recibe los parametros de un caso, devuelve el valor. ---
function Recalcular($caso) {
  # EJEMPLO (interes simple actual/360). Reemplaza por la formula de TU dominio.
  #   return [Math]::Round($caso.saldo * $caso.tasa_anual * $caso.dias / 360, 2)
  throw "Implementa Recalcular() con la formula de tu dominio antes de usar este motor."
}

# --- 2. Cargar los casos golden-master (ajusta el parseo a tu formato: JSON/CSV). ---
function Get-Casos($dir) {
  if (-not (Test-Path $dir)) { throw "No existe FixturesDir: $dir" }
  # EJEMPLO: un JSON por caso con { id, entrada:{...}, esperado:<numero> }.
  Get-ChildItem -Path $dir -Filter '*.json' -Recurse | ForEach-Object {
    Get-Content $_.FullName -Raw | ConvertFrom-Json
  }
}

# --- 3. Correr, comparar, emitir la tabla, decidir exit code. ---
$casos = @(Get-Casos $FixturesDir)
if ($casos.Count -eq 0) { Write-Host "[FALLA] cero casos en $FixturesDir (no apruebo a ciegas)" -ForegroundColor Red; exit 1 }

New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
$tabla = Join-Path $OutDir 'tabla.md'
$fallos = 0
$lineas = @('# Validacion por medicion - corrida', '', '| caso | entrada | obtenido | esperado | delta | ok |', '|---|---|---|---|---|---|')
foreach ($c in $casos) {
  $obtenido = Recalcular $c.entrada
  $esperado = [double]$c.esperado
  $delta = [Math]::Abs($obtenido - $esperado)
  $ok = $delta -le $Tolerancia
  if (-not $ok) { $fallos++ }
  $entradaTxt = ($c.entrada | ConvertTo-Json -Compress)
  $lineas += "| $($c.id) | $entradaTxt | $obtenido | $esperado | $delta | $(if($ok){'PASA'}else{'FALLA'}) |"
}
Set-Content -Path $tabla -Value $lineas -Encoding Ascii
Write-Host "Tabla escrita en $tabla  (forzala al indice: git add -f $tabla)"

if ($fallos -gt 0) {
  Write-Host "[FALLA] $fallos de $($casos.Count) caso(s) fuera de tolerancia (+/-$Tolerancia)." -ForegroundColor Red
  exit 1
}
Write-Host "[PASA] los $($casos.Count) casos cuadran al centavo (+/-$Tolerancia)." -ForegroundColor Green
exit 0
