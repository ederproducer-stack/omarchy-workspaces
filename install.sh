#!/usr/bin/env bash
# Instala o daemon, as regras de persistência e os gestos do omarchy-workspaces.
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BIN="$HOME/.local/bin/omarchy-workspace-compact"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"

install -Dm755 "$SCRIPT_DIR/omarchy-workspace-compact" "$BIN"

# Autostart: só adiciona a linha se ainda não existir.
AUTOSTART="$CONFIG_DIR/hypr/autostart.lua"
touch "$AUTOSTART"
if ! grep -q "omarchy-workspace-compact" "$AUTOSTART"; then
  printf '\no.launch_on_start("omarchy-workspace-compact")\n' >> "$AUTOSTART"
  echo "autostart: linha adicionada em $AUTOSTART"
else
  echo "autostart: já configurado"
fi

# Blocos gerenciados: substitui só o trecho marcado, preservando o resto dos
# arquivos do usuário. Também converte instalações antigas sem marcadores.
python3 - "$SCRIPT_DIR" "$CONFIG_DIR/hypr" <<'PY'
import pathlib
import re
import sys

repo, hypr = (pathlib.Path(p) for p in sys.argv[1:3])


def apply(template_name, target_name, name, legacy_pattern=None):
    template = repo / "config" / template_name
    target = hypr / target_name
    target.touch()

    start = f"-- >>> omarchy-workspaces:{name} >>>"
    end = f"-- <<< omarchy-workspaces:{name} <<<"
    match = re.search(
        rf"{re.escape(start)}.*?{re.escape(end)}\n?",
        template.read_text(),
        re.S,
    )
    if not match:
        sys.exit(f"erro: bloco '{name}' ausente em {template}")
    block = match.group(0)

    text = target.read_text()
    new, count = re.subn(
        rf"{re.escape(start)}.*?{re.escape(end)}\n?",
        lambda _: block,
        text,
        flags=re.S,
    )
    if count == 0 and legacy_pattern:
        new, count = re.subn(legacy_pattern, lambda _: block + "\n", text, flags=re.S)
    if count == 0:
        new = text.rstrip() + "\n\n" + block

    target.write_text(new)


apply(
    "input.lua", "input.lua", "gestures",
    r"-- Enable touchpad gestures for changing workspaces\..*?"
    r"(?=-- Enable touchpad gestures for moving focus)",
)
apply(
    "workspaces-persistent.lua", "hyprland.lua", "persistent",
    r"-- Keep workspaces 1-5 alive.*?\nend\n",
)
PY
echo "gestos e persistência: blocos aplicados em $CONFIG_DIR/hypr"

echo "Pronto. Rode: hyprctl reload"
