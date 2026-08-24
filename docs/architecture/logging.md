# Logging

> Log serve para responder perguntas em produção. Log que ninguém lê é ruído; log que custa
> frame é bug.

## Categorias

```text
GAMEPLAY · TERRITORY · AI · INPUT · UI · SAVE · NETWORK · AUDIO · PERFORMANCE · ERROR
```

Cada categoria liga/desliga de forma independente, em runtime, pelo menu de debug.

## Níveis

| Nível | Uso | Em release |
|---|---|---|
| `DEBUG` | detalhe de desenvolvimento | **removido** |
| `INFO` | marcos (partida iniciou, save escrito, config carregada) | mantido, limitado |
| `WARN` | algo estranho mas recuperável (config fora de faixa, retry de rede) | mantido |
| `ERROR` | falha real (save corrompido, transição inválida, exceção) | mantido + telemetria |

## API

```gdscript
Log.info(Log.Category.GAMEPLAY, "match_started", {"mode": "classic", "bots": 5})
Log.warn(Log.Category.SAVE, "backup_restored", {"reason": "invalid_json"})
Log.error(Log.Category.TERRITORY, "seal_solver_timeout", {"cells": 16384, "us": 8200})
```

- Mensagem é uma **chave estável** em `snake_case`, não uma frase. Dados vão no dicionário.
  Isso permite agregar em produção sem parser frágil.
- Nada de concatenação de string no caminho quente: o dicionário só é montado se o nível
  estiver ativo (`if not Log.enabled(cat, lvl): return` antes de qualquer alocação).
- **Proibido** log por frame. Se precisar acompanhar algo contínuo, use amostragem
  (a cada N ticks) ou o overlay de debug.

## Saídas

| Destino | Quando |
|---|---|
| Console do Godot | editor e builds de debug |
| Arquivo em `user://logs/` | debug e QA; rotação de 5 arquivos × 2 MB |
| Overlay na tela | menu de debug, filtrado por categoria |
| Telemetria remota | só `ERROR` e `WARN` selecionados, a partir de GSD 18, com opt-out |

## Regras de release

- `DEBUG` é removido em build de release por flag de compilação — não fica "só desligado".
- Nenhum log contém PII, token, caminho de arquivo do usuário ou conteúdo de save.
- Falha de logging nunca derruba o jogo: toda a camada é `try`-safe e silenciosa em último caso.
