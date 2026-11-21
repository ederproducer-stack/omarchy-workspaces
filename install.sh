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

# Gestos: garante create_new e forever ligados no input.lua do usuário.
INPUT="$CONFIG_DIR/hypr/input.lua"
if [[ -f $INPUT ]]; then
  if grep -q "workspace_swipe_create_new" "$INPUT"; then
    sed -i 's/workspace_swipe_create_new *= *false/workspace_swipe_create_new = true/' "$INPUT"
    if grep -q "workspace_swipe_forever" "$INPUT"; then
      sed -i 's/workspace_swipe_forever *= *false/workspace_swipe_forever = true/' "$INPUT"
    else
      sed -i '/workspace_swipe_create_new/a\    workspace_swipe_forever = true,' "$INPUT"
    fi
    echo "gestos: opções ajustadas em $INPUT"
  fi
fi

echo "Pronto. Rode: hyprctl reload"
