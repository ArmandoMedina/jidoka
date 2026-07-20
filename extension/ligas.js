// ligas.js — el módulo del ledger de ligas (tools/ligas.json) de la extensión.
//
// JS plano SIN require('vscode') a propósito: así lo prueba `node --test`
// (ligas.test.js) y lo invoca tools/probar-ligas.ps1 con `node -e` para verificar
// el CONTRATO ENTRE STACKS — lo que escribe este módulo lo lee y hace cumplir
// tools/estado-ligas.ps1. La escritura es UTF-8 SIN BOM con newline final:
// exactamente lo que el evaluador PowerShell lee con ReadAllText. Cero deps.

const fs = require('fs');

const DIRECCIONES = ['codigo-a-capacidad', 'capacidad-a-codigo', 'ambas'];
const FUERZAS = ['avisa', 'bloquea'];

/** Lee el ledger. Ausente → vacío (como el evaluador); ilegible → throw (falla cerrado). */
function leer(ledgerPath) {
  if (!fs.existsSync(ledgerPath)) return { ligas: [] };
  const obj = JSON.parse(fs.readFileSync(ledgerPath, 'utf8'));
  if (!obj || !Array.isArray(obj.ligas)) throw new Error('el ledger no trae la clave "ligas"');
  return obj;
}

/** Valida una liga contra el contrato del evaluador. Inválida → throw. */
function validar(liga) {
  if (!liga || !Array.isArray(liga.codigo) || liga.codigo.length === 0) {
    throw new Error("liga sin 'codigo' (array no vacío de globs)");
  }
  if (!Array.isArray(liga.capacidades) || liga.capacidades.length === 0) {
    throw new Error("liga sin 'capacidades' (array no vacío de rutas)");
  }
  if (!DIRECCIONES.includes(liga.direccion)) {
    throw new Error(`dirección '${liga.direccion}' inválida (usa: ${DIRECCIONES.join(' | ')})`);
  }
  if (!FUERZAS.includes(liga.fuerza)) {
    throw new Error(`fuerza '${liga.fuerza}' inválida (usa: ${FUERZAS.join(' | ')})`);
  }
}

/** id legible derivado del primer path de código: 'servidor/pagos.js' → 'pagos', 'extension/*' → 'extension'. */
function slugDe(codigo) {
  const primero = String(codigo[0]).replace(/\/\*+$/, '');
  const base = primero.split('/').pop().replace(/\.[^.]+$/, '');
  const slug = base.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '');
  return slug || 'liga';
}

function escribir(ledgerPath, obj) {
  // JSON legible + newline final, UTF-8 sin BOM (el contrato de encoding con PS).
  fs.writeFileSync(ledgerPath, JSON.stringify(obj, null, 2) + '\n', { encoding: 'utf8' });
}

function mismaLista(a, b) {
  const x = [...a].sort();
  const y = [...b].sort();
  return x.length === y.length && x.every((v, i) => v === y[i]);
}

/**
 * Inserta o actualiza una liga. Si ya existe una con el MISMO código + dirección +
 * fuerza, sus capacidades se REEMPLAZAN por las dadas — la selección del QuickPick
 * es el estado final, así desmarcar una capacidad de verdad la quita (hallazgo de
 * code-review: unir en vez de reemplazar hacía mentir a la UI). Si no existe, se
 * crea con id derivado (o el que venga), sufijado -2/-3 si colisiona.
 */
function upsert(ledgerPath, liga) {
  validar(liga);
  const obj = leer(ledgerPath);
  const existente = obj.ligas.find(
    (l) => Array.isArray(l.codigo) && mismaLista(l.codigo, liga.codigo) && l.direccion === liga.direccion && l.fuerza === liga.fuerza
  );
  if (existente) {
    existente.capacidades = [...liga.capacidades];
    escribir(ledgerPath, obj);
    return existente;
  }
  let id = liga.id || slugDe(liga.codigo);
  const usados = new Set(obj.ligas.map((l) => l.id));
  if (usados.has(id)) {
    let n = 2;
    while (usados.has(`${id}-${n}`)) n++;
    id = `${id}-${n}`;
  }
  const nueva = {
    id,
    codigo: [...liga.codigo],
    capacidades: [...liga.capacidades],
    direccion: liga.direccion,
    fuerza: liga.fuerza,
  };
  obj.ligas.push(nueva);
  escribir(ledgerPath, obj);
  return nueva;
}

/**
 * Quita una ruta del 'codigo' de toda liga que la liste literal; una liga que se
 * queda sin código se elimina entera. Devuelve cuántas ligas se tocaron. Solo
 * escribe si tocó algo (no crea un ledger fantasma ni re-formatea uno ajeno) y
 * tolera ligas malformadas sin 'codigo' (editadas a mano: las deja en paz — el
 * evaluador PS es quien las acusa con su mensaje claro).
 */
function quitar(ledgerPath, ruta) {
  const obj = leer(ledgerPath);
  let tocadas = 0;
  obj.ligas = obj.ligas.filter((l) => {
    if (!Array.isArray(l.codigo) || !l.codigo.includes(ruta)) return true;
    l.codigo = l.codigo.filter((c) => c !== ruta);
    tocadas++;
    return l.codigo.length > 0;
  });
  if (tocadas > 0) escribir(ledgerPath, obj);
  return tocadas;
}

module.exports = { leer, validar, upsert, quitar, slugDe, DIRECCIONES, FUERZAS };
