# GSD 05 — Testes

## Unit

| Arquivo | Cobre |
|---|---|
| `test_bot_profile.gd` | carga, validação de faixa, combinação dificuldade + arquétipo |
| `test_perception.gd` | raio limitado, `ThreatMap`, `OpportunityMap` atualizado por evento |
| `test_bot_actions.gd` | cada uma das 8 ações com contexto montado à mão |
| `test_utility_selection.gd` | escolha da maior, histerese, tempo mínimo de compromisso |
| `test_reaction_error.gd` | atraso aplicado; taxa de erro medida; determinismo com seed |
| `test_bot_safety.gd` | anti-travamento, anti-suicídio, pressão anti-estagnação |
| `test_ai_scheduler.gd` | máx. 2 decisões por tick; nenhum bot esquecido; zero alocação |

## Integration

| Arquivo | Cobre |
|---|---|
| `test_bot_full_match.gd` | 6 bots jogam uma partida Classic inteira sem intervenção |
| `test_bot_obeys_rules.gd` | bot sofre Backwash, Overload e morte igual ao jogador |
| `test_bot_determinism.gd` | mesma seed → mesma partida, 10 execuções |

## Gameplay (headless)

```bash
./tools/dev/simulate.sh 500 --difficulty mixed --report .reports/gsd05.json
```

Invariantes adicionadas:

```text
[ ] nenhum bot parado por mais de 3 s
[ ] toda partida termina dentro do tempo máximo do modo
[ ] nenhum bot ultrapassa a velocidade base (sem power-up)
[ ] toda decisão tem uma ação vencedora válida
```

Métricas: vitórias por arquétipo · duração p50/p95 · território final · Breaks · Backwash ·
Surge máximo · tick p95 · decisões por segundo.

## Legibilidade (playtest)

4 clipes de 20 s, um por arquétipo, mostrados a 5 pessoas: *"o que esse adversário estava
tentando fazer?"*. Meta: ≥ 70 % de acerto para `Hunter`, ≥ 50 % para os demais.

## Benchmarks

B09 `bots_10` · B10 `bots_20` — ambos dentro do orçamento, em dispositivo real.

## Critério de saída

Testes verdes + 500 partidas limpas + legibilidade aprovada + teste de diversão aprovado.
