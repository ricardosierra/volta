# GSD 11 — Requisitos

## Funcionais

| # | Requisito | Verificação |
|---|---|---|
| R11-01 | Item é `Resource`: id, tipo, raridade, preço, fonte de desbloqueio, assets | inspeção |
| R11-02 | Nenhum item altera qualquer variável de simulação | revisão + teste |
| R11-03 | Skins mudam silhueta e núcleo, **nunca** tamanho nem hitbox | teste |
| R11-04 | Arc Styles mudam material, **nunca** a largura efetiva | teste |
| R11-05 | Efeitos de Seal têm a mesma duração e o mesmo custo-alvo | teste + profiler |
| R11-06 | Inventário persistido; item comprado é permanente | teste |
| R11-07 | Desbloqueio por rank, conquista ou compra funciona | 3 testes |
| R11-08 | Preview ao vivo mostra o item aplicado antes de equipar | manual |
| R11-09 | Estados na grade: possuído, equipado, bloqueado (com requisito), comprável | manual |
| R11-10 | Saldo insuficiente é comunicado sem dark pattern | manual |
| R11-11 | Todo cosmético legível em todos os 8 temas | auditoria visual |
| R11-12 | Evento `skin_selected` emitido | teste |

## Não funcionais

| Requisito | Alvo |
|---|---|
| Trocar de item aplica em | < 200 ms |
| Tela de skins carrega | < 300 ms |
| Nenhum item aumenta o custo de render acima do orçamento | profiler |
| Catálogo inicial | ≥ 20 skins, ≥ 12 Arc Styles, 8 temas, 5 efeitos de Seal |
