# .gsd — Get Shit Done

Este diretório é o **cérebro operacional** do projeto. Ele existe para que qualquer sessão de
trabalho — humana ou de agente — possa começar com um comando e terminar com um handoff, sem
reinterpretar o projeto inteiro.

## Arquivos

| Arquivo | O que é |
|---|---|
| [`MASTER_PLAN.md`](MASTER_PLAN.md) | O plano inteiro: 26 fases, objetivo, entregas, protocolo de execução |
| [`STATUS.md`](STATUS.md) | **Estado atual.** Sempre a primeira leitura de qualquer sessão |
| [`DEPENDENCIES.md`](DEPENDENCIES.md) | O que cada fase exige das anteriores |
| [`DECISIONS.md`](DECISIONS.md) | Decisões tomadas no planejamento + as que ainda precisam de humano |
| [`RISKS.md`](RISKS.md) | Riscos com probabilidade, impacto, mitigação e dono |
| [`QUALITY_GATES.md`](QUALITY_GATES.md) | O que precisa ser verdade para uma fase fechar |
| [`BACKLOG.md`](BACKLOG.md) | Tudo que foi adiado, com dono e fase de destino |
| [`COMMANDS.md`](COMMANDS.md) | Os comandos de execução e o que cada um faz |
| [`GLOSSARY.md`](GLOSSARY.md) | Vocabulário do projeto |
| `phases/XX-nome/` | Uma pasta por fase, com 7 documentos |

## Estrutura de uma fase

```text
.gsd/phases/03-territory-engine/
├── README.md         objetivo, escopo, o que entra e o que NÃO entra
├── REQUIREMENTS.md   requisitos funcionais e não funcionais, numerados
├── TASKS.md          tarefas executáveis com ID, passos, testes e DoD
├── ACCEPTANCE.md     critérios de aceite verificáveis
├── TESTS.md          testes que precisam existir e passar
├── RISKS.md          riscos específicos da fase
└── HANDOFF.md        preenchido ao FIM da fase
```

## Regra de ouro

> Uma fase não está concluída porque o código compila. Ela está concluída quando o
> **quality gate** dela fecha inteiro.
