# GSD 07 — UI/UX Foundation

**Status:** ⬜ pendente
**Depende de:** GSD 06
**Branch:** `feature/gsd-07-ui-ux-foundation`
**Tarefas:** 12 · **Prefixo de ID:** `UIUX`

## Objetivo

> Construir o design system e todas as telas, com navegação, responsividade, safe area,
> settings de verdade, i18n e onboarding. A **estrutura** da interface — a aparência final
> vem na GSD 08.

## Escopo

**Entra:**
- Tokens (espaçamento, raio, tipografia, cor semântica, elevação, movimento) como `Resource`
- Componentes: `VButton`, `VIconButton`, `VCard`, `VToggle`, `VSlider`, `VTabs`, `VModal`,
  `VToast`, `VProgressBar`, `VCurrencyPill`, `VRunnerPreview`, `SafeAreaContainer`
- Cena de *showcase* dos componentes
- Telas: Splash, Main Menu, Pause, Results (refinada), Settings, Profile (esqueleto)
- Navegação com pilha, back físico/gesto, transições de 250 ms
- Settings funcionais: Áudio, Controles (com **test drive**), Gráficos, Háptico,
  Acessibilidade, Idioma, Privacidade, Sobre
- i18n com chaves desde o primeiro texto (en + pt-BR)
- Onboarding dentro da partida (6 passos, dirigidos por dado)
- Responsividade de 16:9 a 20:9 + tablet; escala de UI 0,9–1,25

**NÃO entra:**
- Fontes, ícones e paleta definitivos (é 08)
- Telas de Skins, Challenges, Leaderboard, Shop (são 10/11/16/25)
- VFX e som de UI definitivos (é 09)
