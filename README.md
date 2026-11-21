# Omarchy Workspaces

Utilitários para o Hyprland/Omarchy que deixam o uso das áreas de trabalho mais parecido com o GNOME:

1. **Compaction** — se uma área ficar vazia no meio, as janelas da área ocupada mais próxima acima são movidas para preenchê-la (incluindo áreas acima da 5ª, como a 6ª, 7ª...).
2. **Saída ao fechar** — quando você **fecha a última janela da área em que está**, a visão pula automaticamente para a área ocupada mais à esquerda (ou a primeira ocupada acima, se não houver nenhuma à esquerda). Só dispara no evento `closewindow`: mudar para uma área vazia **não** faz a visão sair dela, então você pode abrir algo ali normalmente.
3. **Swipe de 3 dedos** — gesto horizontal do touchpad para trocar de área, com limiares afinados para responder a gestos curtos e sem criar áreas novas automaticamente.

## Arquivos

| Arquivo | Destino |
| --- | --- |
| `omarchy-workspace-compact` | `~/.local/bin/omarchy-workspace-compact` (daemon) |
| `config/autostart.lua` | linha extra em `~/.config/hypr/autostart.lua` |
| `config/input.lua` | bloco de `gestures` em `~/.config/hypr/input.lua` |
| `config/workspaces-persistent.lua` | regras de persistência 1-5 em `~/.config/hypr/hyprland.lua` |
| `plugin/Workspaces.qml` | widget opcional `~/.config/omarchy/plugins/<user>.workspaces/Workspaces.qml` (numeração compacta na barra) |

## Instalação

```bash
git clone https://github.com/ederproducer-stack/omarchy-workspaces.git
cd omarchy-workspaces
./install.sh
```

Numa máquina limpa, `git clone` + `./install.sh` é suficiente: o script copia o daemon, garante o autostart, instala o bloco de gestos afinado e adiciona as regras que mantêm as áreas 1-5 persistentes (necessárias para o swipe ter para onde ir — o Omarchy não as cria por padrão). Ele é idempotente: troca apenas os trechos entre os marcadores `omarchy-workspaces:gestures` e `omarchy-workspaces:persistent` (ou as seções antigas), preservando o restante de `input.lua` e `hyprland.lua`. Depois recarregue o Hyprland:

```bash
hyprctl reload
```

## Como funciona

O daemon ouve o socket de eventos do Hyprland (`.socket2.sock`) e reage a `closewindow` para a saída da área vazia. Em paralelo, a cada 2 segundos ele procura buracos entre as áreas e move janelas das áreas superiores para preenchê-los — isso é o que faz a "mais próxima ocupar o lugar da vazia". Se a área doadora for a que você está vendo, a visão acompanha a janela.

Para inspecionar:

```bash
hyprctl workspaces -j | jq -r '.[] | [.id, (.windows|tostring)] | @tsv'
hyprctl getoption gestures:workspace_swipe_distance
hyprctl getoption gestures:workspace_swipe_cancel_ratio
hyprctl getoption gestures:workspace_swipe_min_speed_to_force
hyprctl getoption gestures:workspace_swipe_create_new
hyprctl getoption gestures:workspace_swipe_forever
```

Os valores afinados são `distance=180`, `cancel_ratio=0.25` (~45 px para confirmar), `min_speed_to_force=8`, `create_new=false` e `forever=false`. Se o gesto ficar sensível demais, suba o `cancel_ratio` para `0.35`.

## Widget de barra (opcional)

`plugin/Workspaces.qml` é um clone de `omarchy.workspaces` que, além de ocultar áreas vazias, renumeia as visíveis (1, 2, 3...) para que não haja buraco visual. Ele está desativado por padrão nesta instalação — a barra usa o widget original com as 5 áreas persistentes. Para usar:

```bash
omarchy plugin clone omarchy.workspaces
cp plugin/Workspaces.qml ~/.config/omarchy/plugins/<seu-user>.workspaces/Workspaces.qml
omarchy bar use <seu-user>.workspaces
```
