#!/usr/bin/env node
'use strict';
// jidoka-method -- instalador de un comando del metodo Jidoka.
// Envuelve tools/instalar.ps1 (el instalador REAL) via PowerShell, en vez de
// duplicar su logica. Requiere PowerShell: 'pwsh' (PowerShell Core, disponible en
// Windows/Mac/Linux) o 'powershell' (Windows). El metodo corre sus gates en
// PowerShell de todos modos, asi que requerirlo para instalar es coherente.
//
// PROBADO: Windows / PowerShell 5.1. La ruta Mac/Linux via pwsh Core DEBERIA
// funcionar (instalar.ps1 pide #Requires -Version 5, y pwsh 7 lo cumple) pero
// AUN NO esta probada -- ver README. No afirmamos cross-platform sin evidencia.

const { spawnSync } = require('child_process');
const path = require('path');
const fs = require('fs');

const pkgRoot = path.resolve(__dirname, '..');
const instalar = path.join(pkgRoot, 'tools', 'instalar.ps1');

function findPwsh() {
  for (const exe of ['pwsh', 'powershell']) {
    try {
      const r = spawnSync(exe, ['-NoProfile', '-Command', '$PSVersionTable.PSVersion.Major'], { encoding: 'utf8' });
      if (r.status === 0) return exe;
    } catch (_) { /* sigue */ }
  }
  return null;
}

// Decide si hace falta -ExecutionPolicy Bypass para correr un .ps1 local sin firmar.
// Por que NO pasarlo siempre: los clasificadores de seguridad de agentes de IA
// DENIEGAN '-ExecutionPolicy Bypass' (parece evasion de defensas), y ahi es justo
// donde 'npx jidoka-method' se corre. La mayoria de las maquinas de desarrollo estan
// en RemoteSigned/Unrestricted y corren scripts locales sin problema SIN el flag.
// Solo Restricted/AllSigned bloquearian un script local sin firmar -> ahi si lo agregamos.
// Si el chequeo falla por lo que sea, caemos al comportamiento previo (agregar Bypass)
// para no romper a un humano en una maquina bloqueada.
function needsBypass(pwsh) {
  try {
    const r = spawnSync(pwsh, ['-NoProfile', '-Command', 'Get-ExecutionPolicy'], { encoding: 'utf8' });
    if (r.status !== 0 || typeof r.stdout !== 'string') return true;   // no se pudo medir -> fallback seguro
    const policy = r.stdout.trim().toLowerCase();
    return policy === 'restricted' || policy === 'allsigned';
  } catch (_) {
    return true;   // el chequeo mismo fallo -> fallback al comportamiento previo (Bypass)
  }
}

const HELP = `
jidoka-method -- siembra el metodo Jidoka (doctrina + ritual + motor Andon) en un repo.

Uso:
  npx jidoka-method init <ruta>                              instalar (pregunta el arquetipo)
  npx jidoka-method init <ruta> --arquetipo docs-as-code --yes   instalar sin prompt
  npx jidoka-method actualizar <ruta>                        bajar la mecanica a un repo instalado
  npx jidoka-method sellar <ruta>                            sellar un repo que convergio a mano

Requiere PowerShell (pwsh en Mac/Linux -- https://aka.ms/powershell; incluido en Windows).
Probado en Windows/PS 5.1; la ruta Mac/Linux (pwsh Core) aun no esta verificada.
`.trim();

function main() {
  const argv = process.argv.slice(2);
  const cmd = argv[0];

  if (!cmd || cmd === '-h' || cmd === '--help' || cmd === 'help') {
    console.log(HELP);
    process.exit(cmd ? 0 : 1);
  }
  if (!['init', 'actualizar', 'sellar'].includes(cmd)) {
    console.error(`[error] subcomando desconocido: ${cmd}\n`); console.error(HELP); process.exit(1);
  }
  if (!fs.existsSync(instalar)) {
    console.error(`[error] no encuentro el instalador empaquetado en ${instalar}`); process.exit(1);
  }
  const pwsh = findPwsh();
  if (!pwsh) {
    console.error('[error] no encontre PowerShell. Instala pwsh (PowerShell Core): https://aka.ms/powershell'); process.exit(1);
  }

  const rest = argv.slice(1);
  const destino = rest[0];
  if (!destino) { console.error('[error] falta la ruta destino. Uso: npx jidoka-method ' + cmd + ' <ruta>'); process.exit(1); }

  // Solo forzamos -ExecutionPolicy Bypass si la politica efectiva bloquearia un
  // script local sin firmar (ver needsBypass): asi no disparamos los guardrails de
  // agentes de IA en las maquinas comunes (RemoteSigned/Unrestricted).
  const psArgs = ['-NoProfile'];
  if (needsBypass(pwsh)) psArgs.push('-ExecutionPolicy', 'Bypass');
  psArgs.push('-File', instalar, '-Destino', path.resolve(destino));
  if (cmd === 'actualizar') psArgs.push('-Actualizar');
  else if (cmd === 'sellar') psArgs.push('-Sellar');
  for (let i = 1; i < rest.length; i++) {
    if (rest[i] === '--arquetipo' && rest[i + 1]) { psArgs.push('-Arquetipo', rest[++i]); }
    else if (rest[i] === '--yes' || rest[i] === '-y') { psArgs.push('-Yes'); }
  }

  const r = spawnSync(pwsh, psArgs, { stdio: 'inherit' });
  process.exit(r.status === null ? 1 : r.status);
}

main();
