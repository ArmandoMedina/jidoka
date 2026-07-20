// ligas.test.js — self-test del módulo del ledger (node --test extension/).
// Corre con el runner nativo de Node (>=18), sin dependencias. Lo dispara
// tools/probar-extension.ps1; el contrato JS↔PS lo cubre probar-ligas.ps1.

const test = require('node:test');
const assert = require('node:assert');
const fs = require('fs');
const os = require('os');
const path = require('path');
const ligas = require('./ligas.js');

function ledgerTmp() {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'ligas-test-'));
  return path.join(dir, 'ligas.json');
}
const LIGA = {
  codigo: ['servidor/pagos.js'],
  capacidades: ['product/capacidades/PAGO-1.md'],
  direccion: 'codigo-a-capacidad',
  fuerza: 'avisa',
};

test('leer: ledger ausente devuelve vacío, no truena', () => {
  assert.deepStrictEqual(ligas.leer(ledgerTmp()), { ligas: [] });
});

test('leer: JSON inválido truena (falla cerrado, como el evaluador PS)', () => {
  const p = ledgerTmp();
  fs.writeFileSync(p, '{ esto no es json', 'utf8');
  assert.throws(() => ligas.leer(p));
});

test('validar: rechaza dirección y fuerza fuera del enum', () => {
  assert.throws(() => ligas.validar({ ...LIGA, direccion: 'diagonal' }));
  assert.throws(() => ligas.validar({ ...LIGA, fuerza: 'sugiere' }));
  assert.throws(() => ligas.validar({ ...LIGA, codigo: [] }));
});

test('upsert: crea con id derivado del código', () => {
  const p = ledgerTmp();
  const l = ligas.upsert(p, LIGA);
  assert.strictEqual(l.id, 'pagos');
  assert.strictEqual(ligas.leer(p).ligas.length, 1);
});

test('upsert: mismo código+dirección+fuerza REEMPLAZA capacidades (desmarcar de verdad quita)', () => {
  const p = ledgerTmp();
  ligas.upsert(p, LIGA);
  ligas.upsert(p, { ...LIGA, capacidades: ['product/capacidades/PAGO-2.md'] });
  const obj = ligas.leer(p);
  assert.strictEqual(obj.ligas.length, 1);
  assert.deepStrictEqual(obj.ligas[0].capacidades, ['product/capacidades/PAGO-2.md']);
});

test('quitar: sin nada que quitar NO escribe (ni crea un ledger fantasma)', () => {
  const p = ledgerTmp();
  assert.strictEqual(ligas.quitar(p, 'no/existe.js'), 0);
  assert.strictEqual(fs.existsSync(p), false);
});

test('quitar: tolera una liga malformada sin codigo (editada a mano) sin tronar', () => {
  const p = ledgerTmp();
  fs.writeFileSync(p, JSON.stringify({ ligas: [{ id: 'rara', capacidades: ['x.md'], direccion: 'ambas', fuerza: 'avisa' }] }, null, 2), 'utf8');
  assert.strictEqual(ligas.quitar(p, 'a.js'), 0);
  assert.strictEqual(ligas.leer(p).ligas.length, 1);
});

test('upsert: id colisionado se sufija -2', () => {
  const p = ledgerTmp();
  ligas.upsert(p, LIGA);
  const l2 = ligas.upsert(p, { ...LIGA, codigo: ['otro/pagos.js'] });
  assert.strictEqual(l2.id, 'pagos-2');
});

test('slugDe: un glob de carpeta cae al nombre de la carpeta', () => {
  assert.strictEqual(ligas.slugDe(['extension/*']), 'extension');
  assert.strictEqual(ligas.slugDe(['tools/estado-gobierno.ps1']), 'estado-gobierno');
});

test('quitar: saca la ruta y elimina la liga que queda vacía', () => {
  const p = ledgerTmp();
  ligas.upsert(p, { ...LIGA, codigo: ['servidor/pagos.js', 'servidor/motor.js'] });
  assert.strictEqual(ligas.quitar(p, 'servidor/motor.js'), 1);
  assert.deepStrictEqual(ligas.leer(p).ligas[0].codigo, ['servidor/pagos.js']);
  assert.strictEqual(ligas.quitar(p, 'servidor/pagos.js'), 1);
  assert.strictEqual(ligas.leer(p).ligas.length, 0);
});

test('escribe UTF-8 SIN BOM con newline final (el contrato de encoding con PS)', () => {
  const p = ledgerTmp();
  ligas.upsert(p, LIGA);
  const buf = fs.readFileSync(p);
  assert.notStrictEqual(buf[0], 0xef, 'no debe llevar BOM');
  assert.strictEqual(buf[buf.length - 1], 0x0a, 'debe terminar en newline');
  JSON.parse(buf.toString('utf8'));
});
