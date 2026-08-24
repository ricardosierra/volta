# GSD 02 — Critérios de aceite

| # | Critério | Como verificar |
|---|---|---|
| A02-01 | O Runner se move com fluidez pela arena | jogar 2 minutos; gravação |
| A02-02 | Latência toque → direção < 50 ms (p95) nos três esquemas | `latency_test` em dispositivo |
| A02-03 | Nenhum toque é descartado em sequência rápida de swipes | teste do buffer + manual |
| A02-04 | O movimento é idêntico em 60, 90 e 120 Hz (só mais suave) | comparação em dois aparelhos |
| A02-05 | A simulação é determinística: mesma seed + mesmos inputs → mesmo estado | teste headless, 10 execuções |
| A02-06 | A simulação roda headless, sem nó visual | teste automatizado |
| A02-07 | A câmera segue sem tremor e sem estourar a borda | gravação de 60 s |
| A02-08 | O ciclo de estados do jogo funciona ponta a ponta | manual + testes de transição |
| A02-09 | `Paused` congela tudo; nada avança em background | teste de integração |
| A02-10 | Todos os valores de movimento vêm de `.tres` | `validate-repo.sh` + revisão |
| A02-11 | Nenhuma classe de simulação importa `presentation/` ou `ui/` | `check_layering` |
| A02-12 | 60 FPS no Mid, 120 FPS no High, com 1 Runner | overlay + `device-results.md` |
| A02-13 | Zero alocação por tick no caminho de movimento | profiler |
| A02-14 | Trocar de esquema de controle em runtime funciona, com test drive | manual |

## Teste de sensação (subjetivo, mas obrigatório)

Três pessoas diferentes jogam 2 minutos e respondem: *"o controle responde?"*, *"você sentiu
que errou por culpa sua ou do jogo?"*. Duas respostas negativas na segunda pergunta **reprovam
a fase**, mesmo com todos os números verdes. É o Pilar 2 tendo mais peso que a planilha.
