# Glossário

## Vocabulário do jogo

| Termo | Definição |
|---|---|
| **Runner** | Entidade controlada por jogador ou bot |
| **Field** | A arena: grid lógico de células + camada visual |
| **Claim** | Território pertencente a um Runner |
| **Arc** | Trilha desenhada fora do próprio Claim; vulnerável |
| **Seal** | Fechar o Arc e converter a região cercada em Claim |
| **Break** | Eliminar um Runner cortando o Arc dele |
| **Backwash** | Penalidade não-letal por tocar o próprio Arc ou uma barreira |
| **Squeeze** | Eliminação por ter o Claim reduzido a zero |
| **Cut** | Bônus por engolir o Arc de um inimigo em um Seal |
| **Surge** | Sistema de combo por encadeamento |
| **Overload** | Estado do Arc no comprimento máximo; a cauda começa a decair |
| **Final Push** | Últimos 30 s de partida, com bônus de pontuação |
| **Spark (✦)** | Moeda soft, ganha jogando |
| **Prism (◈)** | Moeda hard, comprada ou de conquista de marco |
| **Reset Pulse** | Reciclagem de território no modo Endless |

## Vocabulário de processo

| Termo | Definição |
|---|---|
| **GSD** | O sistema de fases deste repositório |
| **Fase** | Bloco de trabalho com escopo, tarefas, aceite e handoff |
| **Quality gate** | Lista de verdades obrigatórias para fechar uma fase |
| **DoD** | *Definition of Done* — quando uma tarefa está realmente pronta |
| **Handoff** | Documento de fim de fase: o que foi feito, decidido e o que vem depois |
| **Invariante** | Afirmação que precisa ser verdadeira em todo tick da simulação |
| **Placeholder rastreado** | Arte/dado temporário com fase e tarefa de substituição |
| **Tier de dispositivo** | Low / Mid / High — o Mid é o aparelho de referência |

## Prefixos de ID de tarefa

`DISC` `REPO` `MOVE` `TERR` `CMBT` `BOTS` `LOOP` `UIUX` `ART` `FEEL` `PROG` `COSM` `MODE`
`MAPS` `PWUP` `API` `ONLN` `MPLY` `ANLT` `PERF` `A11Y` `ANDR` `IOS` `PROD` `LNCH` `POST`

Formato: `PREFIXO-NNN` (ex.: `TERR-004`). Referência em TODO: `TODO(GSD-03/TERR-004): ...`
