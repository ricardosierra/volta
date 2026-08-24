# GSD 07 — Critérios de aceite

| # | Critério | Como verificar |
|---|---|---|
| A07-01 | Nenhum valor visual fora dos tokens | inspeção + lint |
| A07-02 | Os 12 componentes existem, com todos os estados, no showcase | showcase |
| A07-03 | Todas as telas usam `SafeAreaContainer` | inspeção |
| A07-04 | Layout correto em 16:9, 18:9, 19,5:9, 20:9 e tablet | capturas |
| A07-05 | Escala de UI 1,25 sem sobreposição | capturas |
| A07-06 | Alvos de toque ≥ 48 dp | script |
| A07-07 | Back físico e gesto fazem a coisa óbvia em toda tela | manual nos dois sistemas |
| A07-08 | Nenhum texto hardcoded; en e pt-BR completos | `check_i18n.sh` |
| A07-09 | Todas as settings persistem e têm efeito | teste + manual |
| A07-10 | Test drive de controles funciona ao vivo | manual |
| A07-11 | Onboarding: 6 passos, cada um saindo ao ser demonstrado | teste + playtest |
| A07-12 | Primeira execução vai direto para a partida | teste |
| A07-13 | Tempo até o 1º Seal < 25 s para ≥ 80 % dos novos | playtest com 5 pessoas |
| A07-14 | PLAY é o maior alvo de toque do menu | inspeção |
| A07-15 | Nenhuma transição acima de 300 ms | medição |
| A07-16 | UI < 0,8 ms de CPU por frame | profiler |
| A07-17 | Contraste ≥ 4,5:1 (texto) e 3:1 (UI) em todos os tokens | script |

## Gate visual (obrigatório nesta fase)

```text
[ ] alinhamento e espaçamento seguem os tokens
[ ] feedback visual em < 100 ms em toda interação
[ ] contraste verificado
[ ] legível no tema Monochrome
[ ] responsivo em toda a matriz
[ ] safe area respeitada
[ ] nenhuma transição > 300 ms
[ ] sobrevive a UI scale 1,25
[ ] não parece placeholder de engine (dentro do que a arte provisória permite)
```
