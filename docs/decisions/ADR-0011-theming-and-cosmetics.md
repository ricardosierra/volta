# ADR-0011 — Temas e cosméticos

## Context

Temas (paletas) e cosméticos (skins, Arcs, efeitos de Seal) são a espinha da monetização ética e
da acessibilidade visual ao mesmo tempo. Precisam: cobrir UI e gameplay com consistência,
trocar instantaneamente, jamais dar vantagem competitiva, e permitir paletas para daltonismo
com o mesmo mecanismo.

## Decision

**Tema como `Resource` que resolve todos os papéis semânticos de cor** (fundo, superfícies,
texto, destaque, perigo, sucesso, e 8 cores de jogador), aplicado a UI e gameplay pelo mesmo
caminho. Nenhum hex existe fora de um `ThemePalette`.

Cosméticos são **dados**: um item declara o que substitui (silhueta do Runner, material do Arc,
efeito de Seal, moldura de perfil) e nada além disso. Nenhum cosmético toca hitbox, velocidade,
largura do Arc, visibilidade de informação ou qualquer variável de simulação.

Identificação de jogador usa sempre **cor + forma + padrão de preenchimento** — o que torna o
tema `Monochrome` jogável e, de quebra, resolve daltonismo por construção.

## Alternatives

| Alternativa | Por que não |
|---|---|
| **Cores fixas por jogador, sem tema** | Impede acessibilidade e mata uma linha inteira de cosmético não-predatório |
| **Tema só de UI** | O campo de jogo é a maior parte da tela; trocar só a UI é meia-solução visualmente incoerente |
| **Cosmético com efeito de gameplay** | Viola o Pilar 5 e a política de monetização; inegociável |
| **Cores geradas proceduralmente por partida** | Impossível garantir contraste e distinção entre jogadores |

## Consequences

**Positivas:** acessibilidade e cosmético usam o mesmo motor (menos código, mais teste);
troca instantânea; auditoria de contraste automatizável; catálogo cresce sem tocar em regra.

**Negativas / mitigações:**
- Todo shader precisa receber cor por parâmetro (nada hardcoded) → convenção verificada em review.
- Cada tema novo precisa passar por verificação de contraste e simulador de daltonismo → script
  automatizado no CI, não inspeção manual.
- Skins com silhuetas diferentes podem afetar legibilidade → todas respeitam um envelope de
  tamanho comum e são testadas contra o fundo de todos os temas.

## Status

**Accepted** — 2026-08-24. Detalhamento em `docs/art/themes.md`.
