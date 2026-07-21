// extension.js — la extensión de VS Code de Jidoka.
//
// Regla que la gobierna (ADR 0044): **la extensión autora, el gate ejecuta.**
// Esto NO es una capa de gobierno (ADR 0002 sigue intacto): no decide nada, no
// bloquea nada, nadie la llama para que un gate resuelva. Muestra lo que la ley
// ya dice, y —desde R3— escribe declaraciones que los gates deterministas
// (pre-push + required check en CI, fuera del LLM) hacen cumplir.
//
// JavaScript plano a propósito: sin TypeScript, sin build step, sin dependencias
// de runtime — el mismo molde que el toolchain del atlas (docs/atlas/tools/*.mjs).
// Es Jidoka-only: no se siembra a los repos hijos (la mecánica que consume, sí).

const vscode = require('vscode');
const cp = require('child_process');
const fs = require('fs');
const path = require('path');
const ligas = require('./ligas.js');
const contratos = require('./contratos.js');
const ritual = require('./ritual.js');

/** El intérprete del motor: Windows PS 5.1 es la casa; fuera de Windows, pwsh Core. */
function interprete() {
  return process.platform === 'win32' ? 'powershell' : 'pwsh';
}

/** La raíz del repo abierto, o null si no hay carpeta en el workspace. */
function raizDelRepo() {
  const carpetas = vscode.workspace.workspaceFolders;
  if (!carpetas || carpetas.length === 0) return null;
  return carpetas[0].uri.fsPath;
}

/**
 * Corre tools/estado-gobierno.ps1 y devuelve la ruta del .html generado.
 * Falla con un mensaje que dice QUÉ hacer, no solo que algo salió mal.
 */
function generarVista(raiz) {
  return new Promise((resolve, reject) => {
    const script = path.join(raiz, 'tools', 'estado-gobierno.ps1');
    if (!fs.existsSync(script)) {
      reject(new Error(
        'No encontré tools/estado-gobierno.ps1 en este repo. ' +
        'Actualiza el motor de Jidoka (instalar.ps1 -Actualizar) o abre el repo de Jidoka.'
      ));
      return;
    }
    const salida = path.join(raiz, '.jidoka', 'gobierno.html');
    const args = ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', script, '-Repo', raiz, '-Salida', salida];
    cp.execFile(interprete(), args, { cwd: raiz, windowsHide: true }, (err, stdout, stderr) => {
      // La linterna FALLA CERRADO (exit 2) si no puede enumerar los archivos: eso no es
      // un bug de la extensión, es el gate negándose a pintar un verde a ciegas.
      if (err && !fs.existsSync(salida)) {
        reject(new Error((stderr || stdout || err.message || '').trim() || 'la linterna no pudo generar la vista.'));
        return;
      }
      resolve({ salida, stdout: (stdout || '').trim() });
    });
  });
}

/** Cuenta los huérfanos que la linterna reportó, para el aviso de la barra de estado. */
function huerfanosDe(html) {
  const m = /"huerfanos":(\d+)/.exec(html);
  return m ? parseInt(m[1], 10) : null;
}

let panel = null;

async function verGobierno() {
  const raiz = raizDelRepo();
  if (!raiz) {
    vscode.window.showErrorMessage('Jidoka: abre primero la carpeta de un repo para ver su gobierno.');
    return;
  }

  try {
    const { salida } = await vscode.window.withProgress(
      { location: vscode.ProgressLocation.Window, title: 'Jidoka: leyendo la ley del repo…' },
      () => generarVista(raiz)
    );

    const html = fs.readFileSync(salida, 'utf8');

    if (panel) {
      panel.reveal(vscode.ViewColumn.One);
    } else {
      panel = vscode.window.createWebviewPanel(
        'jidokaGobierno',
        'Jidoka — el gobierno',
        vscode.ViewColumn.One,
        { enableScripts: true, retainContextWhenHidden: true }
      );
      panel.onDidDispose(() => { panel = null; });
    }
    panel.webview.html = html;

    const n = huerfanosDe(html);
    if (n !== null) {
      vscode.window.setStatusBarMessage(
        n > 0 ? `Jidoka: ${n} archivo(s) sin gobernar` : 'Jidoka: cero huérfanos',
        6000
      );
    }
  } catch (e) {
    vscode.window.showErrorMessage('Jidoka: ' + (e && e.message ? e.message : String(e)));
  }
}

/** Repinta el grafo si el panel esta abierto (tras escribir el ledger). Silencioso: si falla, el proximo verGobierno lo dira. */
async function refrescarGobierno() {
  if (!panel) return;
  const raiz = raizDelRepo();
  if (!raiz) return;
  try {
    const { salida } = await generarVista(raiz);
    panel.webview.html = fs.readFileSync(salida, 'utf8');
  } catch (e) { /* la vista vieja queda; verGobierno reporta el error real */ }
}

/**
 * Ruta relativa POSIX contra la raiz; una carpeta se guarda como glob 'ruta/*'.
 * Devuelve null si el archivo vive FUERA del workspace ('..' u otra unidad):
 * una liga con esa ruta jamas casaria git ls-files -- naceria ROTA en silencio
 * (hallazgo de code-review; pasa en workspaces multi-root).
 */
function rutaRelativa(raiz, fsPath) {
  let rel = path.relative(raiz, fsPath).split(path.sep).join('/');
  if (rel === '' || rel.startsWith('..') || path.isAbsolute(rel) || rel.includes(':')) return null;
  try { if (fs.statSync(fsPath).isDirectory()) rel = rel + '/*'; } catch (e) { /* si no existe, va tal cual */ }
  return rel;
}

/** Las capacidades del repo (product/capacidades/*.md), con su clave del frontmatter. */
function listarCapacidades(raiz) {
  const dir = path.join(raiz, 'product', 'capacidades');
  if (!fs.existsSync(dir)) return [];
  return fs.readdirSync(dir)
    .filter((f) => f.endsWith('.md') && f !== 'README.md')
    .map((f) => {
      let clave = f.replace(/\.md$/, '');
      try {
        const m = /^\s*clave:\s*(.+?)\s*$/m.exec(fs.readFileSync(path.join(dir, f), 'utf8'));
        if (m) clave = m[1].trim();
      } catch (e) { /* sin frontmatter legible, el basename sirve */ }
      return { clave, path: 'product/capacidades/' + f };
    });
}

/** La seleccion del explorador (multi), o el uri clicado, o el editor activo. */
function archivosSeleccionados(uri, uris) {
  const lista = (uris && uris.length) ? uris : (uri ? [uri] : []);
  if (lista.length === 0 && vscode.window.activeTextEditor) {
    lista.push(vscode.window.activeTextEditor.document.uri);
  }
  return lista.filter((u) => u && u.scheme === 'file');
}

/** Clic derecho -> "Jidoka: ligar a capacidad...": QuickPicks y el modulo escribe el ledger. */
async function ligarCapacidad(uri, uris) {
  const raiz = raizDelRepo();
  if (!raiz) {
    vscode.window.showErrorMessage('Jidoka: abre primero la carpeta de un repo.');
    return;
  }
  const sel = archivosSeleccionados(uri, uris);
  if (sel.length === 0) {
    vscode.window.showErrorMessage('Jidoka: selecciona un archivo en el explorador (o abre uno en el editor).');
    return;
  }
  const codigo = sel.map((u) => rutaRelativa(raiz, u.fsPath)).filter((r) => r !== null);
  if (codigo.length === 0) {
    vscode.window.showErrorMessage('Jidoka: la seleccion vive fuera de la carpeta del repo — una liga asi naceria ROTA (el gate mide rutas del repo).');
    return;
  }
  const caps = listarCapacidades(raiz);
  if (caps.length === 0) {
    vscode.window.showErrorMessage('Jidoka: no hay product/capacidades/*.md en este repo — no hay a que ligar.');
    return;
  }
  const ledgerPath = path.join(raiz, 'tools', 'ligas.json');
  const previas = new Set();
  try {
    for (const l of ligas.leer(ledgerPath).ligas) {
      if (Array.isArray(l.codigo) && Array.isArray(l.capacidades) && l.codigo.some((c) => codigo.includes(c))) {
        l.capacidades.forEach((c) => previas.add(c));
      }
    }
  } catch (e) { /* ledger ilegible: upsert lo reportara */ }

  const picks = await vscode.window.showQuickPick(
    caps.map((c) => ({ label: c.clave, description: c.path, picked: previas.has(c.path) })),
    { canPickMany: true, title: `¿Qué capacidad(es) sostiene ${codigo.join(', ')}?` }
  );
  if (!picks || picks.length === 0) return;

  const dir = await vscode.window.showQuickPick(
    [
      { label: 'codigo-a-capacidad', description: 'si cambia el código sin tocar la capacidad, el gate reclama' },
      { label: 'capacidad-a-codigo', description: 'si cambia la capacidad sin tocar el código, el gate reclama' },
      { label: 'ambas', description: 'vigila en las dos direcciones' },
    ],
    { title: '¿En qué dirección se vigila la relación?' }
  );
  if (!dir) return;

  const fza = await vscode.window.showQuickPick(
    [
      { label: 'avisa', description: 'aviso en push y CI — no detiene nada' },
      { label: 'bloquea', description: 'detiene el push (pre-push y CI corren estricto)' },
    ],
    { title: '¿Con qué fuerza?' }
  );
  if (!fza) return;

  try {
    const liga = ligas.upsert(ledgerPath, {
      codigo,
      capacidades: picks.map((p) => p.description),
      direccion: dir.label,
      fuerza: fza.label,
    });
    vscode.window.setStatusBarMessage(
      `Jidoka: liga '${liga.id}' escrita en tools/ligas.json — el gate la hace cumplir en el próximo push`, 6000
    );
    refrescarGobierno();
  } catch (e) {
    vscode.window.showErrorMessage('Jidoka: no pude escribir la liga: ' + (e && e.message ? e.message : String(e)));
  }
}

/** Clic derecho -> "Jidoka: quitar liga...": saca la ruta del ledger (la liga vacia se elimina). */
async function quitarLiga(uri, uris) {
  const raiz = raizDelRepo();
  if (!raiz) {
    vscode.window.showErrorMessage('Jidoka: abre primero la carpeta de un repo.');
    return;
  }
  const sel = archivosSeleccionados(uri, uris);
  if (sel.length === 0) {
    vscode.window.showErrorMessage('Jidoka: selecciona el archivo cuya liga quieres quitar.');
    return;
  }
  const ledgerPath = path.join(raiz, 'tools', 'ligas.json');
  try {
    let tocadas = 0;
    for (const u of sel) {
      const ruta = rutaRelativa(raiz, u.fsPath);
      if (ruta !== null) tocadas += ligas.quitar(ledgerPath, ruta);
    }
    if (tocadas > 0) {
      vscode.window.setStatusBarMessage(`Jidoka: ${tocadas} liga(s) actualizadas en tools/ligas.json`, 6000);
      refrescarGobierno();
    } else {
      vscode.window.showInformationMessage('Jidoka: ninguna liga lista esa ruta literal en su código — nada que quitar.');
    }
  } catch (e) {
    vscode.window.showErrorMessage('Jidoka: no pude quitar la liga: ' + (e && e.message ? e.message : String(e)));
  }
}

// ============================ CFG-1: la bandeja y el formulario ============================

/** Los nombres de area de la ley (para el cajon del formulario de parametrizar). */
function leerAreas(raiz) {
  try {
    return contratos.leerLey(path.join(raiz, 'tools', 'blast-radius.json'))
      .map((a) => a && a.nombre).filter(Boolean);
  } catch (e) { return []; }
}

/** Corre tools/bandeja.ps1 -Salida y devuelve la ruta del .html. Calca generarVista. */
function generarBandeja(raiz) {
  return new Promise((resolve, reject) => {
    const script = path.join(raiz, 'tools', 'bandeja.ps1');
    if (!fs.existsSync(script)) {
      reject(new Error('No encontré tools/bandeja.ps1 en este repo. Actualiza el motor de Jidoka (instalar.ps1 -Actualizar).'));
      return;
    }
    const salida = path.join(raiz, '.jidoka', 'bandeja.html');
    const args = ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', script, '-Repo', raiz, '-Salida', salida];
    cp.execFile(interprete(), args, { cwd: raiz, windowsHide: true }, (err, stdout, stderr) => {
      if (err && !fs.existsSync(salida)) {
        reject(new Error((stderr || stdout || err.message || '').trim() || 'la bandeja no pudo generarse.'));
        return;
      }
      resolve({ salida });
    });
  });
}

let panelBandeja = null;

/** "Jidoka: ver la bandeja" — el HTML de bandeja.ps1 (pendiente de parametrizar) en un webview. */
async function verBandeja() {
  const raiz = raizDelRepo();
  if (!raiz) { vscode.window.showErrorMessage('Jidoka: abre primero la carpeta de un repo.'); return; }
  try {
    const { salida } = await vscode.window.withProgress(
      { location: vscode.ProgressLocation.Window, title: 'Jidoka: armando la bandeja…' },
      () => generarBandeja(raiz)
    );
    const html = fs.readFileSync(salida, 'utf8');
    if (panelBandeja) {
      panelBandeja.reveal(vscode.ViewColumn.One);
    } else {
      panelBandeja = vscode.window.createWebviewPanel('jidokaBandeja', 'Jidoka — la bandeja', vscode.ViewColumn.One, { enableScripts: true, retainContextWhenHidden: true });
      panelBandeja.onDidDispose(() => { panelBandeja = null; });
    }
    panelBandeja.webview.html = html;
  } catch (e) {
    vscode.window.showErrorMessage('Jidoka: ' + (e && e.message ? e.message : String(e)));
  }
}

/** Escapa para incrustar texto del repo (rutas, nombres de area) en el HTML del formulario. */
function esc(s) {
  return String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;').replace(/'/g, '&#39;');
}

/** El formulario-webview fiel a la maqueta: inyecta la ruta, las areas y los comandos reales. */
function formHtml(doc, areas, comandos) {
  const opcionesArea = areas.map((a) => `<option value="${esc(a)}">${esc(a)}</option>`).join('');
  const casillasCmd = comandos.map((c) => `<label class="chip"><input type="checkbox" value="${esc(c)}"${c === 'arranca' ? ' checked' : ''}><span>${esc(c)}</span></label>`).join('');
  return `<!doctype html><html lang="es"><head><meta charset="utf-8"><meta http-equiv="Content-Security-Policy" content="default-src 'none'; style-src 'unsafe-inline'; script-src 'unsafe-inline';"><style>
  :root{--amber:#e2c08d;--green:#89d185;--red:#f48771;--accent:#1177bb}
  body{font-family:var(--vscode-font-family,"Segoe UI",sans-serif);color:var(--vscode-foreground,#ccc);padding:1.2rem 1.4rem;font-size:13px}
  h1{font-size:1.1rem;margin:0 0 .1rem}.sub{opacity:.7;margin:0 0 1.2rem}
  .field{margin-bottom:1.05rem}.field>label{display:block;font-weight:600;margin-bottom:.4rem}
  .rr{display:flex;gap:.55rem;align-items:flex-start;padding:.45rem .65rem;border:1px solid var(--vscode-panel-border,#3a3a3a);border-radius:6px;margin-bottom:.35rem;cursor:pointer}
  .rr input{margin-top:2px}.rr b{color:var(--vscode-foreground)}.rr small{display:block;opacity:.65;margin-top:.1rem}
  .rr.off{opacity:.4}.sw{display:inline-block;width:10px;height:10px;border-radius:2px;margin-right:.35rem;vertical-align:middle}
  select,input[type=text]{width:100%;background:var(--vscode-input-background,#3c3c3c);color:var(--vscode-input-foreground,#fff);border:1px solid var(--vscode-input-border,#555);border-radius:5px;padding:.45rem .55rem;font-size:13px}
  .row{display:flex;gap:.6rem}.row>*{flex:1}
  .chips{display:flex;flex-wrap:wrap;gap:.4rem}
  .chip{display:flex;gap:.4rem;align-items:center;padding:.32rem .6rem;border:1px solid var(--vscode-panel-border,#3a3a3a);border-radius:14px;cursor:pointer}
  .btns{margin-top:1.2rem;display:flex;gap:.6rem}
  button{border:none;border-radius:5px;padding:.5rem 1rem;font-size:13px;cursor:pointer}
  .primary{background:var(--accent);color:#fff}.ghost{background:transparent;border:1px solid var(--vscode-panel-border,#555);color:var(--vscode-foreground)}
  .hint{margin-top:1.1rem;padding:.6rem .8rem;border-left:3px solid var(--accent);opacity:.75;font-size:12px}
  #areaNueva{display:none;margin-top:.4rem}
  </style></head><body>
  <h1>Parametrizar</h1>
  <p class="sub">${esc(doc)}</p>

  <div class="field"><label>Tipo</label>
    <select id="tipo"><option value="documento">documento</option><option value="dato">dato / spec</option></select>
  </div>

  <div class="field"><label>Régimen de gobierno</label>
    <label class="rr"><input type="radio" name="reg" value="estatuto" checked><span><b><span class="sw" style="background:var(--amber)"></span>estatuto</b><small>estructura gobernada; el contenido es libre; desviarse = DESVIADO, garantía nula</small></span></label>
    <label class="rr"><input type="radio" name="reg" value="libre"><span><b><span class="sw" style="background:var(--green)"></span>libre</b><small>tuyo; se registra pero no se opina del contenido</small></span></label>
    <label class="rr off"><input type="radio" name="reg" value="motor" disabled><span><b><span class="sw" style="background:var(--red)"></span>motor sellado</b><small>no se ofrece — solo lo trae Jidoka de fábrica</small></span></label>
  </div>

  <div class="field"><label>Cajón (área de la ley) &nbsp;+&nbsp; fuerza</label>
    <div class="row">
      <select id="area"><option value="">(ninguno por ahora)</option>${opcionesArea}<option value="__nuevo__">+ cajón nuevo…</option></select>
      <select id="fuerza"><option value="avisa">avisa</option><option value="bloquea">bloquea</option></select>
    </div>
    <input type="text" id="areaNueva" placeholder="nombre del cajón nuevo (p. ej. glosarios)">
  </div>

  <div class="field"><label>¿Qué comandos del ritual la leen con @?</label>
    <div class="chips">${casillasCmd}</div>
  </div>

  <div class="btns">
    <button class="primary" id="ok">Escribir el contrato</button>
    <button class="ghost" id="cancel">Cancelar</button>
  </div>
  <div class="hint">Al confirmar: el contrato en <code>tools/contratos.json</code> (la bandeja lo resta), la regla en <code>tools/blast-radius.json</code> si elegiste cajón, y el <code>@</code> en los comandos marcados. Nada de JSON a mano.</div>

  <script>
    const vscode = acquireVsCodeApi();
    const areaSel = document.getElementById('area');
    areaSel.addEventListener('change', () => {
      document.getElementById('areaNueva').style.display = areaSel.value === '__nuevo__' ? 'block' : 'none';
    });
    document.getElementById('cancel').addEventListener('click', () => vscode.postMessage({ tipo: 'cancelar' }));
    document.getElementById('ok').addEventListener('click', () => {
      const reg = document.querySelector('input[name=reg]:checked');
      const comandos = Array.from(document.querySelectorAll('.chip input:checked')).map((c) => c.value);
      vscode.postMessage({ tipo: 'guardar', datos: {
        tipo: document.getElementById('tipo').value,
        regimen: reg ? reg.value : 'libre',
        area: areaSel.value,
        areaNueva: document.getElementById('areaNueva').value,
        fuerza: document.getElementById('fuerza').value,
        comandos: comandos,
      }});
    });
  </script>
  </body></html>`;
}

/** Clic derecho -> "Jidoka: parametrizar...": el formulario-webview que escribe los ledgers. */
async function parametrizar(uri, uris) {
  const raiz = raizDelRepo();
  if (!raiz) { vscode.window.showErrorMessage('Jidoka: abre primero la carpeta de un repo.'); return; }
  const sel = archivosSeleccionados(uri, uris);
  if (sel.length === 0) { vscode.window.showErrorMessage('Jidoka: selecciona el archivo a parametrizar.'); return; }
  const doc = rutaRelativa(raiz, sel[0].fsPath);
  if (doc === null) { vscode.window.showErrorMessage('Jidoka: el archivo vive fuera de la carpeta del repo.'); return; }

  const areas = leerAreas(raiz);
  const comandos = ['arranca', 'planea', 'que-sigue'].filter((c) =>
    fs.existsSync(path.join(raiz, '.claude', 'commands', 'jidoka', c + '.md')));

  const p = vscode.window.createWebviewPanel('jidokaParametrizar', `Jidoka — parametrizar`, vscode.ViewColumn.One, { enableScripts: true });
  p.webview.html = formHtml(doc, areas, comandos);

  p.webview.onDidReceiveMessage(async (msg) => {
    if (!msg || msg.tipo !== 'guardar') { p.dispose(); return; }
    try {
      const d = msg.datos || {};
      const area = (d.area === '__nuevo__') ? (d.areaNueva || '').trim() : (d.area || '');
      // 1. el contrato en contratos.json — la bandeja lo RESTA (sale de la cola).
      contratos.upsertContrato(path.join(raiz, 'tools', 'contratos.json'), {
        path: doc,
        tipo: d.tipo || 'documento',
        regimen: d.regimen || 'libre',
        area: area || null,
        fuerza: d.fuerza || 'avisa',
        comandos: d.comandos || [],
        estado: 'parametrizado',
      });
      // Se acumulan los AVISOS de lo que falle DESPUES del contrato: una escritura parcial
      // NUNCA se disfraza de exito (el usuario debe poder actuar sobre lo que no quedo).
      const avisos = [];
      // 2. la REGLA en la ley: la ruta a la fuente del area (si eligio cajon).
      let leyMsg = '';
      if (area) {
        try {
          if (contratos.agregarAFuente(path.join(raiz, 'tools', 'blast-radius.json'), area, doc)) leyMsg = ` regla en el area '${area}';`;
        } catch (e) { avisos.push(`no pude escribir la regla en la ley (area '${area}'): ${e && e.message ? e.message : e}`); }
      }
      // 3. el @ en los comandos que la leen (aditiva legal; el estatuto la acepta).
      let arrobas = 0;
      const cmdFallidos = [];
      for (const c of (d.comandos || [])) {
        const cmdPath = path.join(raiz, '.claude', 'commands', 'jidoka', c + '.md');
        if (!fs.existsSync(cmdPath)) { cmdFallidos.push(c + ' (ausente)'); continue; }
        try { if (ritual.insertarArroba(cmdPath, doc)) arrobas++; }
        catch (e) { cmdFallidos.push(c); }
      }
      if (cmdFallidos.length) avisos.push(`no pude insertar el @ en: ${cmdFallidos.join(', ')} (revisa el marcador ${ritual.MARCADOR})`);
      p.dispose();
      if (avisos.length) {
        vscode.window.showWarningMessage(`Jidoka: '${doc}' parametrizado con AVISOS — el contrato quedo, pero: ${avisos.join(' · ')}`);
      } else {
        vscode.window.setStatusBarMessage(`Jidoka: '${doc}' parametrizado —${leyMsg} contrato escrito; ${arrobas} @ insertado(s). La bandeja lo resta.`, 8000);
      }
      if (panelBandeja) verBandeja();
      refrescarGobierno();
    } catch (e) {
      vscode.window.showErrorMessage('Jidoka: no pude parametrizar: ' + (e && e.message ? e.message : String(e)));
    }
  });
}

// ============================ R6: el modo avanzado (firma + reclasificar, ADR 0047) ============================

/** git config <clave> en cwd=raiz; devuelve el valor trim o '' si git falla o no lo tiene. */
function gitConfig(raiz, clave) {
  try {
    return cp.execFileSync('git', ['config', clave], { cwd: raiz, windowsHide: true }).toString().trim();
  } catch (e) { return ''; }
}

/**
 * Clic derecho -> "Jidoka: modo avanzado (reclasificar/firmar)...": escribe un override
 * FIRMADO en contratos.json. Tres piezas del meta-gobierno (ADR 0047): contrasena-ritual
 * (confirmacion tipeada), firma determinista (git config, no inventada), y la accion.
 * Nada de exito falso: si la escritura falla, showErrorMessage (mismo criterio que parametrizar).
 */
async function reclasificar(uri, uris) {
  const raiz = raizDelRepo();
  if (!raiz) { vscode.window.showErrorMessage('Jidoka: abre primero la carpeta de un repo.'); return; }
  const sel = archivosSeleccionados(uri, uris);
  if (sel.length === 0) { vscode.window.showErrorMessage('Jidoka: selecciona el archivo a reclasificar.'); return; }
  const doc = rutaRelativa(raiz, sel[0].fsPath);
  if (doc === null) { vscode.window.showErrorMessage('Jidoka: el archivo vive fuera de la carpeta del repo.'); return; }

  // 1. la ACCION.
  const acciones = [
    { label: 'Aceptar la desviacion', description: 'garantia nula, "bajo tu propio riesgo" — la bandeja lo resta con badge', accion: 'aceptar-desviacion' },
    { label: 'Poner candado IA', description: 'el hook PreToolUse deniega que el agente edite esta pieza', accion: 'candado-on' },
    { label: 'Quitar candado IA', description: 'la IA vuelve a poder editar esta pieza', accion: 'candado-off' },
    { label: 'Reclasificar a estatuto', description: 'estructura gobernada; desviarse = DESVIADO', accion: 'reclasificar-estatuto' },
    { label: 'Reclasificar a libre', description: 'tuyo; se registra pero no se opina del contenido', accion: 'reclasificar-libre' },
  ];
  const pick = await vscode.window.showQuickPick(acciones, { title: `Modo avanzado sobre ${doc} — ¿que accion?` });
  if (!pick) return;

  // 2. el MOTIVO — obligatorio (sin motivo no hay reclasificacion, ADR 0047).
  const motivo = await vscode.window.showInputBox({
    title: 'Motivo (obligatorio) — queda en la firma',
    prompt: 'ADR 0047: sin motivo no hay reclasificacion',
    ignoreFocusOut: true,
  });
  if (motivo === undefined) return;
  if (!motivo.trim()) { vscode.window.showWarningMessage('Jidoka: sin motivo no hay reclasificacion — nada se cambio.'); return; }

  // 3. contrasena-ritual: teclear el nombre de la carpeta del repo (deliberacion, no seguridad).
  const nombreRepo = path.basename(raiz).trim();
  const confirmacion = await vscode.window.showInputBox({
    title: 'Confirmacion deliberada',
    prompt: `Escribe el nombre del repo (${nombreRepo}) para confirmar que sabes lo que haces`,
    ignoreFocusOut: true,
  });
  if (confirmacion === undefined) return;
  if (confirmacion.trim() !== nombreRepo) {
    vscode.window.showWarningMessage('Jidoka: confirmacion no coincide — nada se cambio.');
    return;
  }

  // 4. la firma DETERMINISTA: git config user.name/email + fecha ISO (NO la inventa el agente).
  const quien = gitConfig(raiz, 'user.name');
  if (!quien || !quien.trim()) {
    vscode.window.showErrorMessage('Jidoka: configura git (git config user.name) antes de firmar — la firma se deriva de git, no se inventa (ADR 0047).');
    return;
  }
  const email = gitConfig(raiz, 'user.email');
  const cuando = new Date().toISOString();
  let firma;
  try {
    firma = contratos.firmaDeterminista(quien, email, cuando, motivo.trim());
  } catch (e) {
    vscode.window.showErrorMessage('Jidoka: no pude firmar: ' + (e && e.message ? e.message : String(e)));
    return;
  }

  // 5. confirmacion MODAL final.
  const resumen = `Jidoka: "${pick.label}" sobre ${doc}\nFirma: ${quien}${email ? ' <' + email + '>' : ''}\nMotivo: ${motivo.trim()}`;
  const ok = await vscode.window.showWarningMessage(resumen, { modal: true }, 'Confirmar');
  if (ok !== 'Confirmar') return;

  // 6. escribir el override firmado. Nada de exito falso.
  try {
    contratos.registrarOverride(path.join(raiz, 'tools', 'contratos.json'), { path: doc, accion: pick.accion, firma });
    vscode.window.setStatusBarMessage(`Jidoka: '${doc}' — ${pick.label} firmado por ${quien}. Escrito en tools/contratos.json.`, 8000);
    if (panelBandeja) verBandeja();
    refrescarGobierno();
  } catch (e) {
    vscode.window.showErrorMessage('Jidoka: no pude reclasificar: ' + (e && e.message ? e.message : String(e)));
  }
}

function activate(context) {
  context.subscriptions.push(
    vscode.commands.registerCommand('jidoka.verGobierno', verGobierno),
    vscode.commands.registerCommand('jidoka.ligarCapacidad', ligarCapacidad),
    vscode.commands.registerCommand('jidoka.quitarLiga', quitarLiga),
    vscode.commands.registerCommand('jidoka.parametrizar', parametrizar),
    vscode.commands.registerCommand('jidoka.verBandeja', verBandeja),
    vscode.commands.registerCommand('jidoka.reclasificar', reclasificar)
  );
}

function deactivate() {
  if (panel) { panel.dispose(); panel = null; }
}

module.exports = { activate, deactivate };
