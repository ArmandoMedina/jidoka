#!/usr/bin/env node
// layout.mjs — genera/regenera la geometria (DI) de un .bpmn con bpmn-auto-layout,
// para poder escribir la SEMANTICA (nodos, carriles, gateways, flujos) sin acomodar
// coordenadas a mano. Requiere la devDependency `bpmn-auto-layout`.
//
// Uso:
//   node docs/atlas/tools/layout.mjs <archivo.bpmn> [salida.bpmn]
//   (o `npm run atlas:layout -- <archivo.bpmn>`)
//   Sin [salida] sobrescribe el archivo de entrada.
//
// Limite conocido (bpmn-auto-layout): en colaboraciones solo acomoda el primer
// participante; los lanes/annotations no siempre quedan finos -> revisa el resultado
// en el editor visual (Miragon / demo.bpmn.io) y afina a mano si hace falta.

import { readFileSync, writeFileSync } from 'node:fs';

const [, , inFile, outFile] = process.argv;
if (!inFile) {
  console.error('Uso: node docs/atlas/tools/layout.mjs <archivo.bpmn> [salida.bpmn]');
  process.exit(2);
}

let layoutProcess;
try {
  ({ layoutProcess } = await import('bpmn-auto-layout'));
} catch {
  console.error('Falta la dependencia. Corre:  npm install');
  process.exit(1);
}

const xmlIn = readFileSync(inFile, 'utf8');
const xmlOut = await layoutProcess(xmlIn);
const dest = outFile || inFile;
writeFileSync(dest, xmlOut, 'utf8');
console.log(`Layout regenerado -> ${dest}`);
console.log('Revisa el resultado en el editor visual; afina lanes a mano si hace falta.');
