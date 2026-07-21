// contratos.js — escritores de los ledgers que la extension autora al PARAMETRIZAR una
// pieza (CFG-1, ADR 0046). Modulo JS puro (testeable con node --test, sin VS Code). Calca el
// contrato de encoding de ligas.js: UTF-8 SIN BOM + newline final (lo que el motor PS lee).
//
// Dos ledgers:
//   tools/contratos.json  — INSTANCIA (no-clobber, ADR 0046): el registro por pieza de su
//     parametrizacion (regimen, cajon, fuerza, comandos que leen, firma, candado, estado).
//     La bandeja (bandeja.ps1) LO RESTA: un contrato 'parametrizado' sale de la cola.
//   tools/blast-radius.json — la ley (ARRAY raiz): opcionalmente se agrega la ruta a la
//     'fuente' de un area para que el gate la gobierne de verdad (no solo el registro).
//
// Regla dura: jamas se hace regex-replace del cuerpo. Se PARSEA, se MUTA el objeto, y se
// re-serializa completo. Asi un ledger con formato propio del cliente no se corrompe.

const fs = require('fs');

/** El contrato de encoding con PowerShell: JSON legible + newline final, UTF-8 SIN BOM. */
function escribir(p, obj) {
  fs.writeFileSync(p, JSON.stringify(obj, null, 2) + '\n', { encoding: 'utf8' });
}

// ---------------------------------------------------------------- contratos.json (instancia)
function leerContratos(p) {
  if (!fs.existsSync(p)) return { contratos: [] };
  const obj = JSON.parse(fs.readFileSync(p, 'utf8'));
  if (!obj || !Array.isArray(obj.contratos)) throw new Error('contratos.json no trae la clave "contratos"');
  return obj;
}

/**
 * Inserta o REEMPLAZA (merge por 'path') el contrato de una pieza. Devuelve el contrato final.
 * Preserva las claves previas que no se pisen (p. ej. una firma vieja + un candado nuevo).
 */
function upsertContrato(p, contrato) {
  if (!contrato || !contrato.path) throw new Error('el contrato necesita "path"');
  const obj = leerContratos(p);
  const i = obj.contratos.findIndex((c) => c && c.path === contrato.path);
  if (i >= 0) obj.contratos[i] = { ...obj.contratos[i], ...contrato };
  else obj.contratos.push(contrato);
  escribir(p, obj);
  return (i >= 0) ? obj.contratos[i] : contrato;
}

// ---------------------------------------------------------------- overrides firmados (R6, ADR 0047)
/**
 * La firma DETERMINISTA de un override (ADR 0047): quien/email/cuando/motivo.
 * quien+motivo derivan de git config + la deliberacion; NUNCA los inventa el agente.
 * LANZA si falta 'quien' o 'motivo': una firma sin quien o sin porque es invalida
 * (sin motivo no hay reclasificacion). email y cuando pueden ir vacios pero se incluyen.
 */
function firmaDeterminista(quien, email, cuando, motivo) {
  if (!quien || !String(quien).trim()) throw new Error('la firma necesita "quien" (git config user.name)');
  if (!motivo || !String(motivo).trim()) throw new Error('la firma necesita "motivo" (sin motivo no hay reclasificacion, ADR 0047)');
  return { quien, email: email || '', cuando: cuando || '', motivo };
}

/**
 * Escribe un override FIRMADO en contratos.json (merge por path, no duplica). La bandeja
 * resta lo 'aceptado' con badge de firma; el hook candado-pretooluse lee 'candado'.
 * accion: 'aceptar-desviacion' | 'candado-on' | 'candado-off' | 'reclasificar-estatuto' | 'reclasificar-libre'.
 * NUNCA ofrece 'motor' (ese regimen solo lo trae Jidoka de fabrica). Devuelve el contrato final.
 */
function registrarOverride(contratosPath, { path, accion, firma }) {
  if (!path) throw new Error('registrarOverride necesita "path"');
  // Revalida la firma: un objeto con quien y motivo (reusa el contrato de firmaDeterminista).
  if (!firma || typeof firma !== 'object') throw new Error('registrarOverride necesita una "firma"');
  const firmaValida = firmaDeterminista(firma.quien, firma.email, firma.cuando, firma.motivo);
  const porAccion = {
    'aceptar-desviacion': { estado: 'aceptado' },
    'candado-on': { candado: true },
    'candado-off': { candado: false },
    'reclasificar-estatuto': { regimen: 'estatuto' },
    'reclasificar-libre': { regimen: 'libre' },
  };
  const cambio = porAccion[accion];
  if (!cambio) throw new Error(`accion desconocida: '${accion}' (no se ofrece 'motor', solo lo trae Jidoka de fabrica)`);
  return upsertContrato(contratosPath, { path, ...cambio, firma: firmaValida });
}

// ---------------------------------------------------------------- blast-radius.json (la ley)
function leerLey(p) {
  if (!fs.existsSync(p)) throw new Error('no existe tools/blast-radius.json (la ley)');
  const arr = JSON.parse(fs.readFileSync(p, 'utf8'));
  if (!Array.isArray(arr)) throw new Error('blast-radius.json debe ser un array de areas');
  return arr;
}

/**
 * Agrega la ruta a la 'fuente' de un area (crea el area si no existe). Idempotente: no
 * duplica. Devuelve true si escribio, false si la ruta ya estaba. Respeta el array raiz.
 */
function agregarAFuente(p, area, ruta) {
  if (!area || !ruta) throw new Error('agregarAFuente necesita area y ruta');
  const arr = leerLey(p);
  let a = arr.find((x) => x && x.nombre === area);
  if (!a) {
    a = {
      nombre: area,
      desc: 'area creada desde la extension al parametrizar',
      fuente: [],
      doc_avisa: ['HANDOFF.md'],
      rol: 'escribano',
    };
    arr.push(a);
  }
  if (!Array.isArray(a.fuente)) a.fuente = [];
  if (a.fuente.includes(ruta)) return false;
  a.fuente.push(ruta);
  escribir(p, arr);
  return true;
}

module.exports = { escribir, leerContratos, upsertContrato, firmaDeterminista, registrarOverride, leerLey, agregarAFuente };
