# GSD 06 — Riscos da fase

| # | Risco | P | I | Mitigação |
|---|---|---|---|---|
| F06-01 | **O jogo estar completo e não ser divertido** (RISK-005) | 2 | 5 | playtest obrigatório com 3 pessoas de fora; resultado registrado com honestidade; ajustes de balanceamento são baratos (`.tres`) |
| F06-02 | Fórmula de score gerar números sem sentido (baixos demais, altos demais) | 3 | 3 | teste por termo com valor calculado à mão; 500 partidas mostram a distribuição real; constantes ajustáveis |
| F06-03 | Snowball de Surge decidir a partida cedo (RISK-008) | 2 | 3 | teto, decaimento e medição da distribuição de território final no stress test |
| F06-04 | HUD crescer além dos 5 elementos "porque é útil" | 3 | 2 | regra dura em `hud.md`; inspeção no gate |
| F06-05 | Restart lento e o loop perder o "só mais uma" | 2 | 4 | pré-carregamento durante a animação do resultado; medição < 0,8 s como critério |
| F06-06 | Bônus nomeados inalcançáveis na prática | 2 | 2 | invariante: cada bônus ocorre ao menos uma vez em 500 partidas |
| F06-07 | Analytics acoplado ao gameplay | 2 | 3 | `AnalyticsBridge` como único ponto de tradução; revisão específica no gate |
| F06-08 | Achar que o MVP é "quase" e seguir para a 07 mesmo assim | 3 | 4 | a checklist de 16 itens é binária; item não marcado **impede** o fechamento da fase |

## Riscos globais tocados

- **RISK-005** (não ser divertido): primeiro sinal confiável.
- **RISK-006** (escopo): o marco MVP é o primeiro ponto de decisão real de escopo.
- **RISK-008** (snowball de Surge): primeira medição.
