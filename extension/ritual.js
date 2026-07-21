// ritual.js — inserta un @-include en un comando del ritual, en el MARCADOR estandar
// (comentario HTML), SIN jamas regex-replace del cuerpo (CFG-1, R4). Modulo JS puro
// (node --test). El estatuto del ritual (estado-ritual.ps1) considera CONFORME un @ EXTRA:
// insertar aqui es aditiva legal, y el detector no lo acusa.

const fs = require('fs');

const MARCADOR = '<!-- jidoka:arrobas -->';

/**
 * Inserta la linea '@<arroba>' justo DESPUES del marcador. Idempotente: si el @<arroba> ya
 * esta en el comando (en cualquier parte), no lo duplica. Lanza si no hay marcador (el comando
 * no declara un punto de insercion determinista). Preserva el resto byte a byte y el EOL.
 * Devuelve true si inserto, false si ya estaba.
 */
function insertarArroba(comandoPath, arroba) {
  if (!arroba) throw new Error('insertarArroba necesita la ruta del @');
  const texto = fs.readFileSync(comandoPath, 'utf8');
  const eol = texto.includes('\r\n') ? '\r\n' : '\n';
  const lineas = texto.split(/\r?\n/);
  // Idempotencia por TOKEN, no por substring: '@docs/glo.md' NO debe darse por presente solo
  // porque exista '@docs/glosario.md'. El @<arroba> seguido de fin o de un caracter que no
  // continua la ruta (asi tambien caza la forma backtickeada, p. ej. `@HANDOFF.md`).
  const rx = new RegExp('@' + arroba.replace(/[.*+?^${}()|[\]\\]/g, '\\$&') + '(?![\\w./-])');
  const yaEsta = lineas.some((l) => rx.test(l.replace(/\s+/g, '')));
  if (yaEsta) return false;
  const iMarcador = lineas.findIndex((l) => l.includes(MARCADOR));
  if (iMarcador < 0) throw new Error(`el comando ${comandoPath} no tiene el marcador ${MARCADOR} (punto de insercion)`);
  lineas.splice(iMarcador + 1, 0, '@' + arroba);
  let salida = lineas.join(eol);
  if (!salida.endsWith(eol)) salida += eol;   // el contrato: newline final SIEMPRE (aunque el comando entrara sin el)
  fs.writeFileSync(comandoPath, salida, { encoding: 'utf8' });
  return true;
}

/**
 * Quita la linea '@<arroba>' si esta justo bajo el marcador (o en su bloque). Solo elimina
 * lineas cuyo contenido ES el @<arroba> (no toca prosa que lo mencione). Devuelve cuantas quito.
 */
function quitarArroba(comandoPath, arroba) {
  if (!arroba) throw new Error('quitarArroba necesita la ruta del @');
  const texto = fs.readFileSync(comandoPath, 'utf8');
  const eol = texto.includes('\r\n') ? '\r\n' : '\n';
  const lineas = texto.split(/\r?\n/);
  const objetivo = ('@' + arroba).trim();
  const antes = lineas.length;
  const filtradas = lineas.filter((l) => l.trim() !== objetivo);
  if (filtradas.length === antes) return 0;
  fs.writeFileSync(comandoPath, filtradas.join(eol), { encoding: 'utf8' });
  return antes - filtradas.length;
}

module.exports = { insertarArroba, quitarArroba, MARCADOR };
