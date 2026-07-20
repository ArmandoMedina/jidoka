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

function activate(context) {
  context.subscriptions.push(
    vscode.commands.registerCommand('jidoka.verGobierno', verGobierno)
  );
}

function deactivate() {
  if (panel) { panel.dispose(); panel = null; }
}

module.exports = { activate, deactivate };
