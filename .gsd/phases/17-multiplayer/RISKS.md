# GSD 17 — Riscos da fase

| # | Risco | P | I | Mitigação |
|---|---|---|---|---|
| F17-01 | Divergência de território entre cliente e servidor | 2 | 5 | mesmo código nos dois lados (ADR-0005); checksum de grid periódico no teste de paridade |
| F17-02 | Latência tornar o jogo ruim | 3 | 4 | predição local do próprio Runner; território nunca predito; medição em 4 cenários |
| F17-03 | Custo de infraestrutura inviabilizar | 3 | 3 | teste de carga mede partidas por vCPU antes de qualquer promessa |
| F17-04 | Fase consumir tempo e atrasar o release (RISK-017) | 3 | 5 | fora do caminho crítico; pode ser adiada; entrega é protótipo + relatório, não recurso |
| F17-05 | Godot headless se mostrar ruim como servidor | 2 | 4 | é justamente o que o protótipo mede; se falhar, ADR novo antes de qualquer investimento |
| F17-06 | Reverter Seal negado ficar visualmente feio | 2 | 3 | animação otimista curta; reversão suave; medir frequência real |

## Riscos globais tocados
- **RISK-017** (multiplayer cedo demais) é contido pelo escopo declarado desta fase.
- **RISK-014** (determinismo) é finalmente colocado à prova de verdade.
