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

/** Ruta relativa POSIX contra la raiz; una carpeta se guarda como glob 'ruta/*'. */
function rutaRelativa(raiz, fsPath) {
  let rel = path.relative(raiz, fsPath).split(path.sep).join('/');
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
  const codigo = sel.map((u) => rutaRelativa(raiz, u.fsPath));
  const caps = listarCapacidades(raiz);
  if (caps.length === 0) {
    vscode.window.showErrorMessage('Jidoka: no hay product/capacidades/*.md en este repo — no hay a que ligar.');
    return;
  }
  const ledgerPath = path.join(raiz, 'tools', 'ligas.json');
  const previas = new Set();
  try {
    for (const l of ligas.leer(ledgerPath).ligas) {
      if (l.codigo.some((c) => codigo.includes(c))) l.capacidades.forEach((c) => previas.add(c));
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
    for (const u of sel) tocadas += ligas.quitar(ledgerPath, rutaRelativa(raiz, u.fsPath));
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

function activate(context) {
  context.subscriptions.push(
    vscode.commands.registerCommand('jidoka.verGobierno', verGobierno),
    vscode.commands.registerCommand('jidoka.ligarCapacidad', ligarCapacidad),
    vscode.commands.registerCommand('jidoka.quitarLiga', quitarLiga)
  );
}

function deactivate() {
  if (panel) { panel.dispose(); panel = null; }
}

module.exports = { activate, deactivate };
