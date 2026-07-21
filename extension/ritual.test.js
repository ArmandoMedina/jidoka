const test = require('node:test');
const assert = require('node:assert');
const fs = require('fs');
const os = require('os');
const path = require('path');
const ritual = require('./ritual.js');

function cmdTmp(cuerpo) {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'ritual-test-'));
  const p = path.join(dir, 'arranca.md');
  fs.writeFileSync(p, cuerpo, { encoding: 'utf8' });
  return p;
}

const BASE = [
  '# arranca',
  '',
  '@product/PRODUCT_BRIEF.md',
  '@HANDOFF.md',
  ritual.MARCADOR,
  '',
  '## sigue el ritual',
  'cuerpo intacto',
].join('\n');

test('insertarArroba: inserta @<ruta> justo despues del marcador', () => {
  const p = cmdTmp(BASE);
  const ok = ritual.insertarArroba(p, 'docs/glosario-del-dominio.md');
  assert.strictEqual(ok, true);
  const lineas = fs.readFileSync(p, 'utf8').split('\n');
  const iM = lineas.findIndex((l) => l.includes(ritual.MARCADOR));
  assert.strictEqual(lineas[iM + 1], '@docs/glosario-del-dominio.md', 'el @ va bajo el marcador');
});

test('insertarArroba: idempotente (no duplica si el @ ya esta)', () => {
  const p = cmdTmp(BASE);
  ritual.insertarArroba(p, 'docs/glosario.md');
  const ok2 = ritual.insertarArroba(p, 'docs/glosario.md');
  assert.strictEqual(ok2, false, 'la segunda no inserta');
  const cuenta = (fs.readFileSync(p, 'utf8').match(/@docs\/glosario\.md/g) || []).length;
  assert.strictEqual(cuenta, 1, 'solo una vez');
});

test('insertarArroba: preserva el cuerpo byte a byte (los @ de fabrica y la prosa)', () => {
  const p = cmdTmp(BASE);
  ritual.insertarArroba(p, 'docs/nuevo.md');
  const txt = fs.readFileSync(p, 'utf8');
  assert.ok(txt.includes('@product/PRODUCT_BRIEF.md'), 'el @ de fabrica sigue');
  assert.ok(txt.includes('@HANDOFF.md'), 'el otro @ de fabrica sigue');
  assert.ok(txt.includes('cuerpo intacto'), 'la prosa sigue');
});

test('insertarArroba: idempotencia por TOKEN, no substring (un prefijo NO cuenta como presente)', () => {
  // '@docs/glosario.md' presente; insertar '@docs/glo.md' NO debe darse por hecho.
  const p = cmdTmp(['# t', ritual.MARCADOR, '@docs/glosario.md'].join('\n'));
  const ok = ritual.insertarArroba(p, 'docs/glo.md');
  assert.strictEqual(ok, true, 'un prefijo distinto SI se inserta');
});

test('insertarArroba: garantiza newline final aunque el comando entrara SIN el', () => {
  const p = cmdTmp('# t\n' + ritual.MARCADOR + '\n## body'); // sin newline final
  ritual.insertarArroba(p, 'docs/nuevo.md');
  const buf = fs.readFileSync(p);
  assert.strictEqual(buf[buf.length - 1], 0x0a, 'el archivo debe terminar en newline (el contrato)');
});

test('insertarArroba: lanza si el comando no tiene marcador', () => {
  const p = cmdTmp('# sin marcador\n@HANDOFF.md\ncuerpo');
  assert.throws(() => ritual.insertarArroba(p, 'docs/x.md'), /marcador/);
});

test('quitarArroba: quita la linea del @ (aditiva reversible), sin tocar prosa que lo mencione', () => {
  const p = cmdTmp(BASE + '\n@docs/glosario.md\n> nota: el `@docs/glosario.md` es del cliente');
  const n = ritual.quitarArroba(p, 'docs/glosario.md');
  assert.strictEqual(n, 1, 'quita solo la linea directiva');
  const txt = fs.readFileSync(p, 'utf8');
  assert.ok(txt.includes('nota: el `@docs/glosario.md` es del cliente'), 'la prosa que lo menciona no se toca');
});
