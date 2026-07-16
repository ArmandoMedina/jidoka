#!/usr/bin/env node
// render.mjs — renderiza todos los .bpmn del atlas a SVG en docs/atlas/render/.
// Usa `npx bpmn-to-image` (bpmn-io + Puppeteer) ON-DEMAND: no es dependencia del
// repo, asi que `npm install` queda ligero y Chromium solo se baja la primera vez
// que renderizas (relevante en repos con antivirus).
//
// Uso:
//   node docs/atlas/tools/render.mjs            (o `npm run atlas:render`) -> todos
//   node docs/atlas/tools/render.mjs 10-ritual/16-cierra-as-is.bpmn        -> uno
//
// Salida: docs/atlas/render/<nombre-base>.svg  (versionado, se ve en GitHub/PRs)

import { readdirSync, statSync, mkdirSync } from 'node:fs';
import { join, dirname, basename, relative } from 'node:path';
import { fileURLToPath } from 'node:url';
import { spawnSync } from 'node:child_process';

const atlasDir = join(dirname(fileURLToPath(import.meta.url)), '..');
const outDir = join(atlasDir, 'render');
mkdirSync(outDir, { recursive: true });

function walk(dir) {
  const out = [];
  for (const name of readdirSync(dir)) {
    const p = join(dir, name);
    if (statSync(p).isDirectory()) {
      if (name === 'render' || name === 'tools') continue;
      out.push(...walk(p));
    } else if (name.endsWith('.bpmn')) out.push(p);
  }
  return out;
}

const arg = process.argv[2];
const files = arg ? [join(atlasDir, arg)] : walk(atlasDir);

// bpmn-to-image separa <entrada>;<salida> con ';'. Emitimos rutas RELATIVAS al cwd
// (bajo cmd.exe ';' es literal, no separador de comandos). `npm run` corre desde la
// raiz del paquete, que es el cwd correcto.
const rel = p => relative(process.cwd(), p).split('\\').join('/');
const pairs = files.map(f => `${rel(f)};${rel(join(outDir, basename(f, '.bpmn') + '.svg'))}`);

console.log(`Renderizando ${pairs.length} diagrama(s) a ${relative(process.cwd(), outDir)}/ ...`);
console.log('(primera corrida: npx baja bpmn-to-image + Chromium)\n');

const res = spawnSync('npx', ['--yes', 'bpmn-to-image', ...pairs], {
  stdio: 'inherit',
  shell: true,
});

process.exit(res.status ?? 1);
