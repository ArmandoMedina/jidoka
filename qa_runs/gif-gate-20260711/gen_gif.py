# -*- coding: utf-8 -*-
# Renderiza el GIF del gate Andon bloqueando un push real en SimGhostInputs.
# Todo el texto de salida proviene de una corrida REAL de tools/verificar.ps1
# en un clon de SGI (capturas salida-bloqueo.txt / salida-verde.txt de esta sesion).
from PIL import Image, ImageDraw, ImageFont

FONT = ImageFont.truetype(r"C:\Windows\Fonts\consola.ttf", 15)
FONT_B = ImageFont.truetype(r"C:\Windows\Fonts\consolab.ttf", 15)
FONT_CAP = ImageFont.truetype(r"C:\Windows\Fonts\segoeui.ttf", 16)

W, H = 900, 588
LINE_H = 20
PAD_X, PAD_Y = 14, 40      # deja sitio a la barra de titulo
CAP_H = 34                 # barra de subtitulo abajo
VIEW_LINES = (H - PAD_Y - CAP_H - 10) // LINE_H

BG = (13, 13, 16)
TITLE_BG = (30, 30, 36)
FG = (204, 204, 204)
DIM = (120, 120, 130)
GREEN = (22, 198, 12)
RED = (231, 72, 86)
YELLOW = (249, 241, 165)
CYAN = (97, 214, 214)
WHITE = (242, 242, 242)
CAP_BG = (24, 24, 30)
CAP_FG = (235, 235, 240)

PROMPT = "PS C:\\SimGhostInputs> "

def color_of(line):
    s = line.strip()
    if s.startswith("[OK]"): return GREEN
    if s.startswith("[BLOQUEA]"): return RED
    if s.startswith("[AVISO]"): return YELLOW
    if "PUSH DETENIDO" in s: return RED
    if s.startswith("== ") and "aviso(s) no bloqueante" in s: return YELLOW
    if s.startswith("-- ") or s.startswith("== "): return FG
    if s.startswith("#"): return DIM
    return FG

def wrap(line, width=104):
    if len(line) <= width: return [line]
    out, cur = [], line
    while len(cur) > width:
        cut = cur.rfind(" ", 0, width)
        if cut < 40: cut = width
        out.append(cur[:cut]); cur = "  " + cur[cut:].lstrip()
    out.append(cur)
    return out

frames = []   # (screen_snapshot, duration_ms, caption)
screen = []   # list of (text, color, bold)

def snap(dur, caption):
    frames.append((list(screen), dur, caption))

def add(line, color=None, bold=False):
    for w_ in wrap(line):
        screen.append((w_, color or color_of(line), bold))

def type_cmd(cmd, caption, chunks=4, cursor=True):
    for i in range(1, chunks + 1):
        part = cmd[: max(1, round(len(cmd) * i / chunks))]
        screen.append((PROMPT + part + ("_" if cursor else ""), WHITE, False))
        snap(260 if i < chunks else 420, caption)
        screen.pop()
    screen.append((PROMPT + cmd, WHITE, False))

def out_block(lines, caption, per=180, tail_hold=None):
    for i, ln in enumerate(lines):
        if isinstance(ln, tuple): add(ln[0], ln[1], ln[2] if len(ln) > 2 else False)
        else: add(ln)
        last = i == len(lines) - 1
        snap((tail_hold if (last and tail_hold) else per), caption)

# ---------- fase 1: el commit del agente ----------
cap1 = "1/4 · Un agente de IA cambia la interfaz... y commitea"
snap(500, cap1)
type_cmd('git commit -am "ui: expone el boton de exportar en el paso 4"', cap1)
out_block([
    "[master a650cb1] ui: expone el boton de exportar en el paso 4",
    " 1 file changed, 4 insertions(+)",
    "",
], cap1, per=240, tail_hold=600)

# ---------- fase 2: el gate lo detiene ----------
cap2 = "2/4 · El gate lee el diff, no la palabra del agente"
type_cmd("./tools/verificar.ps1", cap2, chunks=3)
out_block([
    "== Verificar (modo aviso; el CI es el que bloquea) ==",
    "",
    "-- Lint (ruff check) --",
    "All checks passed!",
    "  [OK] sin hallazgos de lint",
    "",
    "-- Formato (ruff format --check) --",
    "  [OK] formato consistente",
    "",
    "-- Tests (pytest) --",
], cap2, per=120)
out_block([
    "........................................................  [ 62%]",
    "........................................................  [100%]",
    "453 passed, 11 skipped in 32.70s",
    "  [OK] tests verdes",
    "",
    "-- Cobertura de tests --",
    "  [AVISO] tocaste fantasma/ sin cambios en tests/. Revisa si el cambio introduce comportamiento nuevo.",
    "",
    "-- Doc-gate (CHANGELOG) --",
    "  [AVISO] tocaste fantasma/ sin actualizar CHANGELOG.md - anotalo en [Unreleased].",
    "",
    "-- Doc-gate (blast-radius seccion 8) --",
], cap2, per=130)
cap2b = "2/4 · La guia de usuario quedo mintiendo -> PUSH DETENIDO"
out_block([
    ("  [BLOQUEA] [ui] tocaste fantasma/ui/ng_helpers.py sin docs/guia-usuario.md (interfaz NiceGUI v2.0). Rol: revisor-visual -> pasalo al escribano.", RED, True),
], cap2b, per=900)
out_block([
    "  [AVISO] [ui] considera actualizar docs/ux-patterns.md. El CI re-verifica esto.",
    "",
    ("== 1 bloqueo(s) de doc-drift. PUSH DETENIDO. ==", RED, True),
    "   Sincroniza los docs duenos (pasalo al escribano) y reintenta, o 'git push --no-verify' a proposito.",
    "   (+4 aviso[s] no bloqueante[s] arriba.)",
], cap2b, per=260, tail_hold=3200)

# ---------- fase 3: se sincroniza el doc ----------
cap3 = "3/4 · Se actualiza la guia de usuario y se commitea"
out_block([""], cap3, per=200)
add("# (editas docs/guia-usuario.md: documentas el boton nuevo)", DIM)
snap(700, cap3)
type_cmd('git commit -am "docs: guia de usuario al dia (boton exportar)"', cap3)
out_block([
    "[master 275eb64] docs: guia de usuario al dia (boton exportar)",
    " 1 file changed, 2 insertions(+)",
    "",
], cap3, per=240, tail_hold=500)

# ---------- fase 4: el gate deja pasar ----------
cap4 = "4/4 · Codigo y docs en sincronia -> el push pasa"
type_cmd("./tools/verificar.ps1", cap4, chunks=2)
out_block([
    "== Verificar (modo aviso; el CI es el que bloquea) ==",
    "  [OK] sin hallazgos de lint",
    "  [OK] formato consistente",
    "453 passed, 11 skipped in 32.78s",
    "  [OK] tests verdes",
    "",
    "-- Doc-gate (blast-radius seccion 8) --",
], cap4, per=140)
cap4b = "4/4 · El mismo check corre en CI como requerido: el muro real"
out_block([
    ("  (avisos arriba; nada que BLOQUEA en blast-radius)", YELLOW, False),
    ("  [OK] grafo de docs integro (o solo avisos)", GREEN, False),
    "",
    ("== 4 aviso(s) no bloqueante(s). El CI hara cumplir lint/formato/tests. ==", YELLOW, True),
], cap4b, per=300, tail_hold=3800)

# ---------- render ----------
imgs, durs = [], []
for shot, dur, caption in frames:
    im = Image.new("RGB", (W, H), BG)
    d = ImageDraw.Draw(im)
    # barra de titulo
    d.rectangle([0, 0, W, 30], fill=TITLE_BG)
    d.ellipse([12, 10, 22, 20], fill=(255, 95, 86))
    d.ellipse([30, 10, 40, 20], fill=(255, 189, 46))
    d.ellipse([48, 10, 58, 20], fill=(39, 201, 63))
    d.text((70, 7), "PowerShell 5.1 - SimGhostInputs (repo publico, metodo Jidoka)", font=FONT_CAP, fill=(180, 180, 190))
    # viewport: ultimas N lineas
    view = shot[-VIEW_LINES:]
    y = PAD_Y
    for text, color, bold in view:
        d.text((PAD_X, y), text, font=(FONT_B if bold else FONT), fill=color)
        y += LINE_H
    # barra de subtitulo
    d.rectangle([0, H - CAP_H, W, H], fill=CAP_BG)
    d.text((PAD_X, H - CAP_H + 7), caption, font=FONT_CAP, fill=CAP_FG)
    imgs.append(im)
    durs.append(dur)

# exporta PNGs + archivo concat para ffmpeg (per-frame duration confiable)
import os
outdir = r"C:\Users\jose_\AppData\Local\Temp\claude\C--Repositorios-jidoka\40c59faa-e40d-41a9-9824-1cbf6e144c1d\scratchpad\frames"
os.makedirs(outdir, exist_ok=True)
lines = []
for i, (im, dur) in enumerate(zip(imgs, durs)):
    p = os.path.join(outdir, f"f{i:03d}.png")
    im.save(p)
    lines.append(f"file 'f{i:03d}.png'")
    lines.append(f"duration {dur/1000:.3f}")
lines.append(f"file 'f{len(imgs)-1:03d}.png'")  # el concat exige repetir el ultimo
with open(os.path.join(outdir, "concat.txt"), "w") as fh:
    fh.write("\n".join(lines))
print(f"frames: {len(imgs)}  dur_total: {sum(durs)/1000:.1f}s")
