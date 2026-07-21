const test = require('node:test');
const assert = require('node:assert');
const fs = require('fs');
const os = require('os');
const path = require('path');
const contratos = require('./contratos.js');

function tmp(nombre) {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'contratos-test-'));
  return path.join(dir, nombre);
}

test('upsertContrato: crea un contrato nuevo por path', () => {
  const p = tmp('contratos.json');
  contratos.upsertContrato(p, { path: 'docs/glosario.md', regimen: 'libre', estado: 'parametrizado' });
  const obj = contratos.leerContratos(p);
  assert.strictEqual(obj.contratos.length, 1);
  assert.strictEqual(obj.contratos[0].path, 'docs/glosario.md');
  assert.strictEqual(obj.contratos[0].estado, 'parametrizado');
});

test('upsertContrato: mismo path hace MERGE (no duplica; conserva claves previas)', () => {
  const p = tmp('contratos.json');
  contratos.upsertContrato(p, { path: 'docs/x.md', regimen: 'libre', firma: { quien: 'Ana' } });
  contratos.upsertContrato(p, { path: 'docs/x.md', candado: true });
  const obj = contratos.leerContratos(p);
  assert.strictEqual(obj.contratos.length, 1, 'no debe duplicar por path');
  assert.strictEqual(obj.contratos[0].candado, true, 'gana la clave nueva');
  assert.strictEqual(obj.contratos[0].firma.quien, 'Ana', 'conserva la clave previa');
});

test('upsertContrato sin path lanza', () => {
  const p = tmp('contratos.json');
  assert.throws(() => contratos.upsertContrato(p, { regimen: 'libre' }), /path/);
});

test('escribe UTF-8 SIN BOM con newline final (el contrato de encoding con PS)', () => {
  const p = tmp('contratos.json');
  contratos.upsertContrato(p, { path: 'docs/x.md', regimen: 'libre' });
  const buf = fs.readFileSync(p);
  assert.notStrictEqual(buf[0], 0xef, 'no debe llevar BOM');
  assert.strictEqual(buf[buf.length - 1], 0x0a, 'debe terminar en newline');
  JSON.parse(buf.toString('utf8'));
});

test('agregarAFuente: agrega la ruta a un area existente (idempotente)', () => {
  const p = tmp('blast-radius.json');
  contratos.escribir(p, [{ nombre: 'guias', fuente: ['docs/guias/*'] }]);
  assert.strictEqual(contratos.agregarAFuente(p, 'guias', 'docs/glosario.md'), true, 'escribe la primera vez');
  assert.strictEqual(contratos.agregarAFuente(p, 'guias', 'docs/glosario.md'), false, 'no duplica la segunda');
  const arr = contratos.leerLey(p);
  assert.ok(Array.isArray(arr), 'la ley sigue siendo un array raiz');
  assert.deepStrictEqual(arr[0].fuente, ['docs/guias/*', 'docs/glosario.md']);
});

test('agregarAFuente: crea el area si no existe (cajon nuevo), sin tocar las demas', () => {
  const p = tmp('blast-radius.json');
  contratos.escribir(p, [{ nombre: 'guias', fuente: ['docs/guias/*'] }]);
  contratos.agregarAFuente(p, 'glosarios', 'docs/glosario.md');
  const arr = contratos.leerLey(p);
  assert.strictEqual(arr.length, 2, 'agrega un area, no pisa la existente');
  const nueva = arr.find((a) => a.nombre === 'glosarios');
  assert.ok(nueva, 'creo el area nueva');
  assert.deepStrictEqual(nueva.fuente, ['docs/glosario.md']);
  assert.strictEqual(arr[0].nombre, 'guias', 'el area previa intacta');
});
