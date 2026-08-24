# ADR-0009 — UI, escala de tela e design system

## Context

UI mobile portrait, precisando funcionar de 16:9 a 20:9, em tablets, com notch, Dynamic Island,
gestos de sistema, escala de UI ajustável (0,9–1,25) e i18n (en + pt-BR). E precisa parecer
premium, não "tutorial de engine".

## Decision

**Godot Control nativo** + **design system próprio** baseado em tokens (`Resource`), sem
biblioteca de UI de terceiros.

- `stretch_mode = canvas_items`, `aspect = expand`, resolução base **1080 × 1920**.
- Toda tela é envolvida por um `SafeAreaContainer` próprio, que lê
  `DisplayServer.get_display_safe_area()` e reage a mudanças em runtime.
- Tokens de espaçamento, raio, tipografia, cor semântica, elevação e movimento em `.tres`;
  nenhum componente conhece hex nem pixel mágico.
- Componentes (`VButton`, `VCard`, `VModal`, …) como cenas reutilizáveis com script tipado, mais
  uma cena de *showcase* para inspeção visual e regressão.
- Todo texto por chave de tradução desde GSD 07 — nunca "traduzimos depois".

## Alternatives

| Alternativa | Por que não |
|---|---|
| **Biblioteca de UI de terceiros** | Dependência no caminho crítico, estilo alheio ao nosso, risco de abandono |
| **UI desenhada em shader/canvas próprio** | Perde acessibilidade, foco, entrada de texto e layout automático de graça |
| **`viewport` stretch** | Resultado embaçado em telas altas; ruim para texto |
| **Layout absoluto por resolução** | Insustentável com 5 proporções e escala de UI |
| **Escala automática por DPI só** | Ignora preferência do jogador; acessibilidade exige controle manual |

## Consequences

**Positivas:** um lugar para mudar a aparência do jogo inteiro; troca de tema instantânea;
consistência forçada por construção; sem dependência externa.

**Negativas / mitigações:**
- Construir componentes dá trabalho inicial → concentrado em GSD 07, e paga em todas as fases
  seguintes.
- Tokens exigem disciplina → PR com valor fora de token é rejeitado; showcase serve de vitrine
  e de regressão visual.

**Compromissos:** alvo de toque ≥ 48 dp; nada interativo a menos de 16 dp da safe area; nenhuma
transição acima de 300 ms; layout precisa sobreviver a UI scale 1,25 sem sobreposição.

## Status

**Accepted** — 2026-08-24. Detalhamento em `docs/ui/design-system.md`.
