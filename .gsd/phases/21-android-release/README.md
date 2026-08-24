# GSD 21 — Android Release

**Status:** ⬜ pendente · **Depende de:** GSD 20 · **Tarefas:** 9 · **Prefixo:** `ANDR`
**Branch:** `feature/gsd-21-android-release`

## Objetivo

> Uma build de produção assinada, validada e pronta para o Google Play — com ícones, splash,
> permissões, privacidade e assets de loja em ordem.

## Dependências humanas
`H-01` (marca — **prazo é antes desta fase**), `H-02` (conta do Play), `H-06` (política de
privacidade publicada). Sem elas, a fase entrega a build mas não publica.

## Escopo
Build de release, assinatura via CI, AAB com split por ABI, ícones adaptativos, splash,
permissões, Data Safety, política de privacidade, assets de loja, validação em dispositivo,
teste interno no Play.

**NÃO entra:** rollout público (é 24).
