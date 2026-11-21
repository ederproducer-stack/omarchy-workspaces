# Omarchy Workspaces

Utilitários para o Hyprland/Omarchy que deixam o uso das áreas de trabalho mais parecido com o GNOME:

1. **Compaction** — se uma área ficar vazia no meio, as janelas da área ocupada mais próxima acima são movidas para preenchê-la (incluindo áreas acima da 5ª, como a 6ª, 7ª...).
2. **Saída ao fechar** — quando você **fecha a última janela da área em que está**, a visão pula automaticamente para a área ocupada mais à esquerda (ou a primeira ocupada acima, se não houver nenhuma à esquerda). Só dispara no evento `closewindow`: mudar para uma área vazia **não** faz a visão sair dela, então você pode abrir algo ali normalmente.
3. **Swipe de 3 dedos** — gesto horizontal do touchpad para trocar de área, com criação de novas áreas ao passar da última.

## Arquivos

| Arquivo | Destino |
| --- | --- |
| `omarchy-workspace-compact` | `~/.local/bin/omarchy-workspace-compact` (daemon) |
| `config/autostart.lua` | linha extra em `~/.config/hypr/autostart.lua` |
| `config/input.lua` | seção `gestures` em `~/.config/hypr/input.lua` |
| `config/workspaces-persistent.lua` | referência das regras de persistência |
| `plugin/Workspaces.qml` | widget opcional `~/.config/omarchy/plugins/<user>.workspaces/Workspaces.qml` (numeração compacta na barra) |

## Instalação

```bash
git clone https://github.com/ederproducer-stack/omarchy-workspaces.git
cd omarchy-workspaces
./install.sh
```

O `install.sh` copia o daemon, garante a linha de autostart e aplica as opções de gesto. Depois recarregue o Hyprland:

```bash
hyprctl reload
```

## Como funciona

O daemon ouve o socket de eventos do Hyprland (`.socket2.sock`) e reage a `closewindow` para a saída da área vazia. Em paralelo, a cada 2 segundos ele procura buracos entre as áreas e move janelas das áreas superiores para preenchê-los — isso é o que faz a "mais próxima ocupar o lugar da vazia". Se a área doadora for a que você está vendo, a visão acompanha a janela.

Para inspecionar:

```bash
hyprctl workspaces -j | jq -r '.[] | [.id, (.windows|tostring)] | @tsv'
hyprctl getoption gestures:workspace_swipe_create_new
hyprctl getoption gestures:workspace_swipe_forever
```

## Widget de barra (opcional)

`plugin/Workspaces.qml` é um clone de `omarchy.workspaces` que, além de ocultar áreas vazias, renumeia as visíveis (1, 2, 3...) para que não haja buraco visual. Ele está desativado por padrão nesta instalação — a barra usa o widget original com as 5 áreas persistentes. Para usar:

```bash
omarchy plugin clone omarchy.workspaces
cp plugin/Workspaces.qml ~/.config/omarchy/plugins/<seu-user>.workspaces/Workspaces.qml
omarchy bar use <seu-user>.workspaces
```
