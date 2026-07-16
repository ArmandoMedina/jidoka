#!/usr/bin/env node
// sellar-plataforma.mjs — escribe en cada .bpmn/.dmn el atributo que el editor
// Miragon lee para NO preguntar "Camunda 7 u 8" al abrir. Nuestros diagramas son
// documentacion (isExecutable=false); marcamos Camunda 7 solo para que abran directo.
// Idempotente: si el archivo ya lo tiene, lo deja igual.
// Uso: node docs/atlas/tools/sellar-plataforma.mjs   (o `npm run atlas:sellar`)

import { readFileSync, writeFileSync, readdirSync, statSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const atlasDir = join(dirname(fileURLToPath(import.meta.url)), '..');
const NS = 'http://camunda.org/schema/modeler/1.0';
const PLATAFORMA = 'Camunda Platform';   // Camunda 7
const VERSION = '7.18.0';

function walk(dir) {
  const out = [];
  for (const name of readdirSync(dir)) {
    const p = join(dir, name);
    if (statSync(p).isDirectory()) { if (name !== 'render' && name !== 'tools') out.push(...walk(p)); }
    else if (name.endsWith('.bpmn') || name.endsWith('.dmn')) out.push(p);
  }
  return out;
}

let sellados = 0, yaEstaban = 0;
for (const f of walk(atlasDir)) {
  let xml = readFileSync(f, 'utf8');
  if (/modeler:executionPlatformVersion=/.test(xml)) { yaEstaban++; continue; }

  // Localiza la etiqueta raiz de definiciones (<bpmn:definitions ...> o <definitions ...>)
  xml = xml.replace(/<((?:\w+:)?definitions)\b([^>]*)>/, (m, tag, attrs) => {
    let a = attrs;
    if (!/xmlns:modeler=/.test(a)) a += ` xmlns:modeler="${NS}"`;
    a += ` modeler:executionPlatform="${PLATAFORMA}" modeler:executionPlatformVersion="${VERSION}"`;
    return `<${tag}${a}>`;
  });
  writeFileSync(f, xml, 'utf8');
  sellados++;
}

console.log(`Sellados: ${sellados} · ya lo tenian: ${yaEstaban}`);
console.log('Cierra y reabre las pestañas en VS Code: ya no preguntara la plataforma.');
