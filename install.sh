#!/usr/bin/env bash
# Instala o daemon e as opções de gesto do omarchy-workspaces.
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

# Gestos: substitui o bloco gerenciado pela versão afinada deste repo.
# Idempotente e preserva o restante do input.lua do usuário.
INPUT="$CONFIG_DIR/hypr/input.lua"
TEMPLATE="$SCRIPT_DIR/config/input.lua"
touch "$INPUT"
python3 - "$TEMPLATE" "$INPUT" <<'PY'
import pathlib
import re
import sys

template = pathlib.Path(sys.argv[1])
target = pathlib.Path(sys.argv[2])
START = "-- >>> omarchy-workspaces:gestures >>>"
END = "-- <<< omarchy-workspaces:gestures <<<"

match = re.search(
    rf"{re.escape(START)}.*?{re.escape(END)}\n?",
    template.read_text(),
    re.S,
)
if not match:
    sys.exit("erro: bloco de gestos ausente em config/input.lua")
block = match.group(0)

text = target.read_text()
new, count = re.subn(
    rf"{re.escape(START)}.*?{re.escape(END)}\n?",
    lambda _: block,
    text,
    flags=re.S,
)
if count == 0:
    # Instalações antigas: troca a seção de gestos sem marcadores.
    legacy = re.compile(
        r"-- Enable touchpad gestures for changing workspaces\..*?"
        r"(?=-- Enable touchpad gestures for moving focus)",
        re.S,
    )
    new, count = legacy.subn(lambda _: block + "\n", text)
if count == 0:
    new = text.rstrip() + "\n\n" + block

target.write_text(new)
PY
echo "gestos: bloco afinado aplicado em $INPUT"

echo "Pronto. Rode: hyprctl reload"
