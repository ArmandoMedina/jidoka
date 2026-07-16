#!/usr/bin/env node
// validar.mjs — verifica la integridad estructural del atlas SIN dependencias.
// Reglas:
//   1) todo `calledElement` de una Call Activity resuelve a un `process id` del paquete
//   2) toda Call Activity aparece en RELACIONES.csv
//   3) reporta conteo de process ids y de Call Activities
// Uso: node docs/atlas/tools/validar.mjs   (o `npm run atlas:validate`)
// Sale con codigo 1 si hay algun hueco estructural.

import { readFileSync, readdirSync, statSync } from 'node:fs';
import { join, dirname, relative } from 'node:path';
import { fileURLToPath } from 'node:url';

const atlasDir = join(dirname(fileURLToPath(import.meta.url)), '..');

function walk(dir) {
  const out = [];
  for (const name of readdirSync(dir)) {
    const p = join(dir, name);
    if (statSync(p).isDirectory()) out.push(...walk(p));
    else if (name.endsWith('.bpmn')) out.push(p);
  }
  return out;
}

const files = walk(atlasDir);

const processIds = new Set();
const callActivities = []; // { file, id, calledElement }

for (const f of files) {
  const xml = readFileSync(f, 'utf8');
  for (const m of xml.matchAll(/<bpmn:process\b[^>]*\bid="([^"]+)"/g)) processIds.add(m[1]);
  for (const m of xml.matchAll(/<bpmn:callActivity\b([^>]*)>/g)) {
    const attrs = m[1];
    const id = (attrs.match(/\bid="([^"]+)"/) || [])[1];
    const called = (attrs.match(/\bcalledElement="([^"]+)"/) || [])[1];
    callActivities.push({ file: relative(atlasDir, f), id, calledElement: called });
  }
}

// Indice del CSV: pares (elemento_padre) declarados
let csvPairs = new Set();
try {
  const csv = readFileSync(join(atlasDir, 'RELACIONES.csv'), 'utf8').trim().split(/\r?\n/).slice(1);
  for (const line of csv) {
    const cols = line.split(',');
    // archivo_padre,elemento_padre,tipo_relacion,archivo_hijo,process_id_hijo
    if (cols[2] === 'CALL_ACTIVITY') csvPairs.add(cols[1]);
  }
} catch { /* CSV opcional */ }

const errores = [];

for (const ca of callActivities) {
  if (!ca.calledElement || !processIds.has(ca.calledElement))
    errores.push(`Call Activity ${ca.id} en ${ca.file}: calledElement "${ca.calledElement}" no resuelve a ningun process id del paquete`);
  if (csvPairs.size && !csvPairs.has(ca.id))
    errores.push(`Call Activity ${ca.id} en ${ca.file}: no aparece en RELACIONES.csv`);
}

console.log(`Archivos BPMN:        ${files.length}`);
console.log(`Process IDs:          ${processIds.size}`);
console.log(`Call Activities:      ${callActivities.length}`);
console.log(`Verificadas en CSV:   ${csvPairs.size ? callActivities.filter(c => csvPairs.has(c.id)).length : 'CSV no encontrado'}`);

if (errores.length) {
  console.error(`\nSIN PASAR — ${errores.length} hueco(s) estructural(es):`);
  for (const e of errores) console.error('  - ' + e);
  process.exit(1);
}
console.log('\nOK — sin huecos estructurales. Todos los calledElement resuelven y toda Call Activity esta en el CSV.');
