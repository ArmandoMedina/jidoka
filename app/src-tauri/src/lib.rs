// La app de la tuberia (Jidoka). R3 (mitad UI): la app deja de ser teatro EN LAS LECTURAS.
// Al abrir, invoca el motor PS (tools/tuberia-datos.ps1) que emite la foto consolidada del
// repo (piezas+aristas+regimenes+bandeja reales, ADR 0048) y la pinta. El motor PS es el
// UNICO lector; la app solo invoca. Las ESCRITURAS siguen teatro (R4/R5-UI, otro paso).
//
// Por que std::process::Command y NO el plugin shell: menos superficie de permisos (el
// hallazgo de review en R2 fue "permisos minimos"). std::process no necesita capability
// alguna. En Windows agregamos CREATE_NO_WINDOW (0x08000000) para que powershell.exe no
// parpadee una consola negra al abrir. El plugin shell quedo registrado en R2 sin usarse:
// se retira (menos superficie). El plugin dialog SI se usa (selector de carpeta).

use std::fs;
use std::path::PathBuf;
use std::process::Command;
use tauri::Manager;
use tauri_plugin_dialog::DialogExt;

#[cfg(windows)]
use std::os::windows::process::CommandExt;
#[cfg(windows)]
const CREATE_NO_WINDOW: u32 = 0x08000000;

// El archivo (en el app-data dir de Tauri) donde recordamos el ultimo repo abierto.
fn ruta_memoria(app: &tauri::AppHandle) -> Result<PathBuf, String> {
    let dir = app
        .path()
        .app_data_dir()
        .map_err(|e| format!("no pude resolver el app-data dir: {e}"))?;
    fs::create_dir_all(&dir).map_err(|e| format!("no pude crear el app-data dir: {e}"))?;
    Ok(dir.join("repo.txt"))
}

// Valida que <carpeta> sea un repo con Jidoka instalado (tiene tools/blast-radius.json).
fn es_repo_jidoka(repo: &str) -> bool {
    PathBuf::from(repo).join("tools").join("blast-radius.json").exists()
}

// Ejecuta tools/tuberia-datos.ps1 sobre el repo y devuelve su stdout (el JSON consolidado).
// exit != 0 -> Err con el stderr. La app JS hace JSON.parse del retorno.
#[tauri::command]
fn cargar_datos(repo: String) -> Result<String, String> {
    if repo.trim().is_empty() {
        return Err("no hay repo seleccionado".into());
    }
    let script = PathBuf::from(&repo).join("tools").join("tuberia-datos.ps1");
    if !script.exists() {
        return Err(format!(
            "no encontre {} -- el repo no tiene el motor de la tuberia",
            script.display()
        ));
    }

    let mut cmd = Command::new("powershell.exe");
    cmd.args([
        "-NoProfile",
        "-ExecutionPolicy",
        "Bypass",
        "-File",
        &script.to_string_lossy(),
        "-Repo",
        &repo,
    ]);
    #[cfg(windows)]
    cmd.creation_flags(CREATE_NO_WINDOW);

    let out = cmd
        .output()
        .map_err(|e| format!("no pude lanzar powershell.exe: {e}"))?;

    if !out.status.success() {
        let err = String::from_utf8_lossy(&out.stderr);
        let msg = if err.trim().is_empty() {
            format!("tuberia-datos.ps1 fallo (exit {:?})", out.status.code())
        } else {
            err.trim().to_string()
        };
        return Err(msg);
    }

    Ok(String::from_utf8_lossy(&out.stdout).to_string())
}

// Devuelve el ultimo repo recordado. Err si no hay ninguno o ya no es un repo Jidoka.
#[tauri::command]
fn repo_actual(app: tauri::AppHandle) -> Result<String, String> {
    let mem = ruta_memoria(&app)?;
    let repo = fs::read_to_string(&mem)
        .map_err(|_| "no hay repo recordado".to_string())?
        .trim()
        .to_string();
    if repo.is_empty() {
        return Err("no hay repo recordado".into());
    }
    if !es_repo_jidoka(&repo) {
        return Err(format!("el repo recordado ({repo}) ya no tiene tools/blast-radius.json"));
    }
    Ok(repo)
}

// Abre el selector de carpeta, valida tools/blast-radius.json y persiste el repo elegido.
#[tauri::command]
fn elegir_repo(app: tauri::AppHandle) -> Result<String, String> {
    let carpeta = app
        .dialog()
        .file()
        .set_title("Elige la carpeta del repo Jidoka")
        .blocking_pick_folder();

    let carpeta = match carpeta {
        Some(c) => c.to_string(),
        None => return Err("no se eligio ninguna carpeta".into()),
    };

    if !es_repo_jidoka(&carpeta) {
        return Err(format!(
            "no encontre tools/blast-radius.json en {carpeta} -- ¿es un repo con Jidoka instalado?"
        ));
    }

    let mem = ruta_memoria(&app)?;
    fs::write(&mem, &carpeta).map_err(|e| format!("no pude recordar el repo: {e}"))?;
    Ok(carpeta)
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_dialog::init())
        .invoke_handler(tauri::generate_handler![
            cargar_datos,
            repo_actual,
            elegir_repo
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
