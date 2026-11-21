-- Trecho para ~/.config/hypr/hyprland.lua (mantém as áreas 1-5 persistentes).
-- Omarchy já registra as regras de persistência por padrão; este arquivo
-- documenta o comportamento usado neste projeto.
for i = 1, 5 do
  hl.workspace_rule({ workspace = tostring(i), persistent = true })
end
