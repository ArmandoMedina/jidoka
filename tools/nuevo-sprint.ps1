#Requires -Version 5
# nuevo-sprint.ps1 - el generador de sprints conformes. Copia el molde canonico
# (kit/.jidoka/templates/sprint-plan.md) a docs/sprints/sprint-<slug>-plan.md con el
# titulo ya puesto, para que un sprint NAZCA conforme al ledger docs-gobernados.json
# (familia docs/sprints/*-plan.md) y no se desvie a mano. Con -Entrega genera ademas
# el record de cierre desde sprint-entrega.md. No sobrescribe: si el archivo existe,
# se detiene (exit 1). ASCII a proposito, PS 5.1. UTF-8 SIN BOM en la salida (mismo
# contrato de encoding que el resto de los .md). Ver ADR del molde de sprints.
#
# Uso:  ./tools/nuevo-sprint.ps1 -Nombre "El molde de X"            (crea el plan)
#       ./tools/nuevo-sprint.ps1 -Nombre "El molde de X" -Slug molde-x
#       ./tools/nuevo-sprint.ps1 -Nombre "El molde de X" -Entrega   (crea tambien la entrega)

param(
  [Parameter(Mandatory = $true)][string]$Nombre,
  [string]$Slug = '',
  [switch]$Entrega,
  [string]$Repo = ''
)

$ErrorActionPreference = 'Stop'
if (-not $Repo) { $Repo = Split-Path -Parent $PSScriptRoot }
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

# Deriva el slug del nombre si no se dio: minusculas, sin acentos, espacios a guion,
# solo [a-z0-9-]. Asi "El molde de X" -> "el-molde-de-x".
function Get-Slug($s) {
  $t = $s.ToLowerInvariant()
  $formD = $t.Normalize([System.Text.NormalizationForm]::FormD)
  $sb = New-Object System.Text.StringBuilder
  foreach ($ch in $formD.ToCharArray()) {
    if ([System.Globalization.CharUnicodeInfo]::GetUnicodeCategory($ch) -ne [System.Globalization.UnicodeCategory]::NonSpacingMark) { [void]$sb.Append($ch) }
  }
  $t = $sb.ToString().Normalize([System.Text.NormalizationForm]::FormC)
  $t = ($t -replace '[^a-z0-9]+', '-').Trim('-')
  return $t
}

if (-not $Slug) { $Slug = Get-Slug $Nombre }
if (-not $Slug) { Write-Host "  [ERROR] no pude derivar un slug de '$Nombre'." -ForegroundColor Red; exit 1 }

# Genera un doc desde su molde: reemplaza el H1 placeholder por el titulo real y
# escribe UTF-8 sin BOM. No sobrescribe.
function New-Doc($molde, $destino, $tituloH1) {
  $moldeAbs = Join-Path $Repo $molde
  $destAbs = Join-Path $Repo $destino
  if (-not (Test-Path -LiteralPath $moldeAbs)) { Write-Host "  [ERROR] molde ausente: $molde" -ForegroundColor Red; exit 1 }
  if (Test-Path -LiteralPath $destAbs) { Write-Host "  [ERROR] ya existe: $destino (no se sobrescribe)" -ForegroundColor Red; exit 1 }
  $texto = [System.IO.File]::ReadAllText($moldeAbs, $utf8NoBom)
  # el molde empieza con '# Sprint N — [nombre...]' o '# Sprint N — [nombre] · Entrega'
  $texto = [regex]::Replace($texto, '^# Sprint N [^\r\n]*', $tituloH1)
  [System.IO.File]::WriteAllText($destAbs, $texto, $utf8NoBom)
  Write-Host ("  [OK] generado: {0}" -f $destino) -ForegroundColor Green
}

Write-Host "== Nuevo sprint (nace conforme al molde) =="
$emDash = [char]0x2014
New-Doc 'kit/.jidoka/templates/sprint-plan.md' "docs/sprints/sprint-$Slug-plan.md" ("# Sprint $emDash $Nombre")
if ($Entrega) {
  New-Doc 'kit/.jidoka/templates/sprint-entrega.md' "docs/sprints/sprint-$Slug-entrega.md" ("# Sprint $emDash $Nombre $emDash Entrega")
}
Write-Host "  (verifica con: tools/estado-docs.ps1 -- la familia docs/sprints/*-plan.md debe salir CONFORME)"
exit 0
