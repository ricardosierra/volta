# GSD 11 — Testes

## Unit
`test_catalog.gd` (ids únicos, schema sem campo de gameplay) · `test_inventory.gd` ·
`test_loadout.gd` (slot nunca vazio, item inexistente ignorado) ·
`test_unlock_service.gd` (3 fontes, saldo insuficiente, compra dupla)

## Equidade (obrigatórios)
```text
[ ] hitbox idêntica em todas as skins
[ ] largura efetiva de Arc idêntica em todos os estilos
[ ] duração e custo idênticos em todos os efeitos de Seal
[ ] custo de render dentro do orçamento para qualquer combinação
```

## Visual
Matriz item × 8 temas, com capturas anexadas. Teste cego de ameaça com 5 pessoas.

## Manual
```text
[ ] preview reflete exatamente o que será aplicado
[ ] a grade comunica os estados sem texto
[ ] comprar é claro e reversível até a confirmação
[ ] nenhum item esconde informação do adversário
```
