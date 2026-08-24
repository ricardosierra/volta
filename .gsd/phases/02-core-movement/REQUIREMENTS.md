# GSD 02 — Requisitos

## Funcionais

| # | Requisito | Verificação |
|---|---|---|
| R02-01 | Simulação roda em `_physics_process` a 60 Hz fixo | teste + inspeção |
| R02-02 | Visual interpolado entre ticks, suave em 60/90/120 Hz | teste em dispositivo de 120 Hz |
| R02-03 | Runner tem posição e direção contínuas, com taxa máxima de giro | teste unitário |
| R02-04 | Velocidade e taxa de giro vêm de `RunnerBalance` (nunca literais) | inspeção + `validate-repo.sh` |
| R02-05 | Driver de swipe reconhece direção com zona morta em **mm físicos** | teste em dois aparelhos de densidades diferentes |
| R02-06 | Driver de joystick flutuante funciona e é configurável | manual |
| R02-07 | Driver relativo (steering) funciona | manual |
| R02-08 | Buffer de input garante que nenhum toque é descartado durante uma virada | teste unitário com dois comandos no mesmo tick |
| R02-09 | Runner mantém a direção ao soltar o dedo (configurável) | manual |
| R02-10 | Câmera segue com suavização e lookahead, sem tremor | manual + gravação |
| R02-11 | Runner é contido pelos limites do Field (desliza na borda) | teste de integração |
| R02-12 | FSM do jogo implementada com transições declaradas e validadas | testes de todas as transições |
| R02-13 | `Paused` congela a simulação por completo | teste de integração |
| R02-14 | Latência toque → mudança de direção < 50 ms | medição instrumentada em dispositivo |
| R02-15 | Simulação roda headless sem nenhum nó visual | teste headless que move o Runner 600 ticks |

## Não funcionais

| # | Requisito |
|---|---|
| N02-01 | Zero alocação por tick no caminho de movimento |
| N02-02 | Tick de simulação < 0,5 ms com 1 Runner |
| N02-03 | 60 FPS estáveis no aparelho Mid; 120 FPS no High |
| N02-04 | Nenhuma classe de simulação importa `presentation/` ou `ui/` |
| N02-05 | Trocar de driver de input não exige mudar nenhuma linha de simulação |
