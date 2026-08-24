# GSD 22 — iOS Release

**Status:** ⬜ pendente · **Depende de:** GSD 20 · **Tarefas:** 8 · **Prefixo:** `IOS`
**Branch:** `feature/gsd-22-ios-release`

## Objetivo

> Build iOS validada no TestFlight, com assinatura, ícones, launch screen, privacidade e
> assets de loja prontos.

## Dependências humanas
`H-02` (conta Apple Developer), `H-06` (política de privacidade). macOS com Xcode 15+ já
disponível.

## Escopo
Export Godot → projeto Xcode → `xcodebuild` → IPA → TestFlight. Ícones completos, launch
screen em storyboard, Privacy Nutrition Label, entitlements mínimos, validação em iPhone e iPad.
