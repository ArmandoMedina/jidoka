// La app de la tuberia (Jidoka). R2: el cascaron fiel -- la UI ES la maqueta
// (app/ui/index.html, copia byte-fiel de docs/analisis/maqueta-tuberia-202607.html),
// datos aun hardcodeados (teatro). Los plugins shell y dialog se registran YA aunque
// R2 no los use: R3+ los necesita (el motor PS como unico escritor / selector de carpeta)
// y asi el build queda listo sin volver a tocar el cableado nativo.
#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_shell::init())
        .plugin(tauri_plugin_dialog::init())
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
