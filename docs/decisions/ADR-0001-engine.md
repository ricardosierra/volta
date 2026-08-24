# ADR-0001 — Engine e versão

## Context

Precisamos de uma engine para um arcade 2D mobile, com exigências claras: 60 FPS estáveis em
aparelho intermediário, ciclo de iteração rápido, export para Android e iOS, possibilidade de
rodar a simulação **headless** (para testes e stress test de milhares de partidas) e custo zero
de licença. A equipe já tem experiência com Godot em outro projeto mobile em produção
(Godot 4.3 instalado e validado nesta máquina).

## Decision

**Godot 4.3 stable**, GDScript com tipagem estática, renderer **Mobile** (Vulkan) com fallback
**Compatibility** (GLES3). A versão é pinada em `.godot-version`, usada igualmente por
desenvolvedores e pelo CI.

C# está fora: aumenta o tamanho do build, complica o export para iOS e não traz ganho onde
importa (o gargalo previsto é o `SealSolver`, que é otimizável em GDScript com arrays
empacotados e, em último caso, por GDExtension).

Por que 4.3 e não a mais nova disponível: é a versão instalada, validada e reproduzível hoje,
tanto localmente quanto no CI. Um projeto que não consegue rodar a própria engine no dia 1
não tem velocidade nenhuma. A avaliação de upgrade acontece em **GSD 20** (compatibilidade de
dispositivos), quando o custo de migrar é conhecido e o benefício — principalmente
interpolação física 2D nativa — pode ser medido contra a nossa interpolação manual.

## Alternatives

| Alternativa | Por que não |
|---|---|
| **Unity** | Licenciamento imprevisível, build maior, iteração mais lenta para um 2D simples, headless mais burocrático |
| **Godot com C#** | Build maior, atrito no export iOS, sem ganho no caminho quente |
| **Engine própria (SDL/raylib)** | Meses gastos em ferramentas que a Godot já dá prontas (export mobile, UI, áudio, editor) |
| **Flutter / motor web** | Controle de frame e input insuficientes para o alvo de latência |
| **Godot mais recente que 4.3** | Ganhos reais (interpolação 2D nativa), mas exige baixar/validar toolchain agora; adiado para GSD 20 com critério explícito |

## Consequences

**Positivas:** iteração rápida; `--headless --script` viabiliza os testes de gameplay que
sustentam a estratégia de QA; export mobile pronto; sem custo de licença; um único código de
simulação reaproveitável no servidor autoritativo (ADR-0005).

**Negativas / mitigações:**
- GDScript é mais lento que C#/C++ → orçamento de performance explícito, arrays empacotados,
  zero alocação no caminho quente, benchmarks desde GSD 03.
- 4.3 não tem interpolação física 2D nativa → interpolação manual dos visuais (ADR-0014).
- Ecossistema mobile menor que o da Unity → nada de dependência de plugin de terceiros no core.

**Compromissos:** versão pinada; upgrade só por ADR novo; nenhum plugin de terceiros no
caminho de simulação.

## Status

**Accepted** — 2026-08-24.
