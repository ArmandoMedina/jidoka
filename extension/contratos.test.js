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

// ------------------------------------------------------------------ R6: firma + override (ADR 0047)

test('firmaDeterminista: lanza si falta quien o motivo (firma sin quien/porque es invalida)', () => {
  assert.throws(() => contratos.firmaDeterminista('', 'a@b.c', '2026-07-21', 'porque si'), /quien/);
  assert.throws(() => contratos.firmaDeterminista('Ana', 'a@b.c', '2026-07-21', ''), /motivo/);
  assert.throws(() => contratos.firmaDeterminista(undefined, '', '', 'motivo'), /quien/);
  assert.throws(() => contratos.firmaDeterminista('Ana', '', '', undefined), /motivo/);
  // email y cuando pueden ir vacios pero se incluyen en la firma.
  const f = contratos.firmaDeterminista('Ana', '', '', 'el porque');
  assert.deepStrictEqual(f, { quien: 'Ana', email: '', cuando: '', motivo: 'el porque' });
});

test('registrarOverride aceptar-desviacion: estado aceptado + firma, y NO duplica por path', () => {
  const p = tmp('contratos.json');
  const firma = { quien: 'Ana', email: 'a@b.c', cuando: '2026-07-21T00:00:00Z', motivo: 'lo asumo' };
  contratos.registrarOverride(p, { path: 'docs/x.md', accion: 'aceptar-desviacion', firma });
  contratos.registrarOverride(p, { path: 'docs/x.md', accion: 'aceptar-desviacion', firma });
  const obj = contratos.leerContratos(p);
  assert.strictEqual(obj.contratos.length, 1, 'no debe duplicar por path');
  assert.strictEqual(obj.contratos[0].estado, 'aceptado');
  assert.strictEqual(obj.contratos[0].firma.quien, 'Ana');
});

test('registrarOverride candado-on luego candado-off: merge, un solo contrato', () => {
  const p = tmp('contratos.json');
  const firma = { quien: 'Ana', email: '', cuando: '', motivo: 'lo sello' };
  contratos.registrarOverride(p, { path: 'docs/x.md', accion: 'candado-on', firma });
  let obj = contratos.leerContratos(p);
  assert.strictEqual(obj.contratos[0].candado, true, 'candado-on');
  contratos.registrarOverride(p, { path: 'docs/x.md', accion: 'candado-off', firma: { quien: 'Ana', motivo: 'lo abro' } });
  obj = contratos.leerContratos(p);
  assert.strictEqual(obj.contratos.length, 1, 'un solo contrato (merge por path)');
  assert.strictEqual(obj.contratos[0].candado, false, 'candado-off gana');
});

test('registrarOverride con firma incompleta (sin motivo) lanza', () => {
  const p = tmp('contratos.json');
  assert.throws(
    () => contratos.registrarOverride(p, { path: 'docs/x.md', accion: 'candado-on', firma: { quien: 'Ana' } }),
    /motivo/
  );
});
