# GSD 06 — Critérios de aceite 🏁 MVP

## Critérios da fase

| # | Critério | Como verificar |
|---|---|---|
| A06-01 | Countdown funciona e o input já é lido | teste + manual |
| A06-02 | Score bate com a fórmula documentada, termo a termo | testes unitários |
| A06-03 | Surge sobe, decai e zera corretamente | testes |
| A06-04 | Os 9 bônus disparam nas condições certas e só nelas | 18 testes (9 positivos + 9 negativos) |
| A06-05 | Final Push aplica o multiplicador e é perceptível | teste + manual |
| A06-06 | As três condições de fim funcionam | 3 testes |
| A06-07 | Empate é resolvido de forma determinística | teste do desempate em cascata |
| A06-08 | Tela de resultado mostra tudo que importa, com contagem animada | manual |
| A06-09 | PLAY AGAIN reinicia em < 0,8 s, em um toque | medição |
| A06-10 | Recorde pessoal persiste entre sessões | teste |
| A06-11 | Eventos de analytics emitidos com as propriedades certas | teste com adapter falso |
| A06-12 | HUD tem exatamente os 5 elementos permitidos | inspeção |
| A06-13 | Nenhum popup interrompe o controle durante a partida | inspeção + manual |
| A06-14 | 500 partidas headless: 0 crash, 0 invariante violada | `simulate.sh 500` |

## Checklist do MVP (marco)

```text
[ ] o jogo inicia
[ ] o Runner se move
[ ] o Arc funciona
[ ] o Claim fecha
[ ] a área é conquistada
[ ] inimigos existem
[ ] Arcs podem ser atacados
[ ] Runners podem morrer
[ ] bots jogam
[ ] a partida termina
[ ] score existe
[ ] resultado existe
[ ] restart existe
[ ] UI consistente (dentro do provisório)
[ ] 60 FPS estáveis no aparelho-alvo
[ ] nenhum bug crítico aberto
```

## Playtest de MVP (obrigatório)

Três pessoas de fora, sem instrução verbal, jogam 10 minutos. Coletar:

```text
[ ] tempo até o primeiro Seal (alvo: < 25 s)
[ ] elas entenderam o objetivo sozinhas?
[ ] elas jogaram mais de uma partida por vontade própria?
[ ] o que mais incomodou?
```

Resultado registrado no `HANDOFF.md` **com honestidade**, inclusive se for ruim. Este é o
primeiro dado real sobre RISK-005 (o jogo pode não ser divertido) — e é muito mais barato
descobrir isso agora do que na GSD 20.
