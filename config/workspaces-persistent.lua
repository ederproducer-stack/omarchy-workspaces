-- >>> omarchy-workspaces:persistent >>>
-- Mantém as áreas 1-5 vivas para o swipe de 3 dedos ter para onde ir.
-- Omarchy NÃO registra persistência por padrão: este trecho é necessário.
for i = 1, 5 do
  hl.workspace_rule({ workspace = tostring(i), persistent = true })
end
-- <<< omarchy-workspaces:persistent <<<
