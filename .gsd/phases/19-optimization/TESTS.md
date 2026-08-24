# GSD 19 — Testes

## Benchmarks
B01–B15 completos, nos 3 tiers, com build de release.

## Regressão funcional
Toda a suíte (unit, integration, gameplay) + 2 000 partidas headless após as otimizações.
Comparar distribuição de vitórias e duração com o baseline anterior — otimização **não pode**
mudar comportamento.

## Medições em dispositivo
```text
[ ] FPS p50/p10 em Low, Mid, High
[ ] frame time e hitches em 3 min
[ ] tick por subsistema
[ ] GPU e draw calls
[ ] RSS ao longo de 10 partidas
[ ] cold start, menu→partida, results→partida
[ ] bateria em 1 h; térmica em 20 min
[ ] tamanho do AAB e do IPA
```

## Comparação visual
Vídeo lado a lado antes/depois das otimizações de GPU.
