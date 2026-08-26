# iOS

Plataforma secundária no cronograma, **não** na qualidade.

## Alvo

| | |
|---|---|
| iOS mínimo | 14.0 |
| Dispositivos | iPhone (primário) e iPad (suportado) |
| Arquitetura | arm64 |
| Renderer | `Mobile` (Metal) |
| Orientação | portrait travado (iPhone); portrait no iPad também, com layout adaptado |
| Bundle ID | `com.ricardosierra.volta` |

## Preparação (GSD 22)

1. Export template 4.3 stable + Xcode 15+.
2. Conta de desenvolvedor, App ID, provisioning profile de distribuição.
3. Godot exporta um projeto Xcode; o build final sai do `xcodebuild` (script em `tools/ci`).
4. Ícones: conjunto completo do `AppIcon` (o iOS não perdoa faltando um tamanho).
5. Launch screen: storyboard com a cor de fundo do tema + logo. Sem imagem estática por tamanho.
6. `CFBundleShortVersionString` = semver; `CFBundleVersion` = build monotônico.

## Entitlements e privacidade

- Nenhum entitlement especial no v0.1.0.
- **Privacy Nutrition Label**: no v0.1.0, "Data Not Collected". Muda em GSD 18 quando
  analytics entrar — e a mudança é uma tarefa explícita, não um detalhe.
- `NSUserTrackingUsageDescription`: **não** usamos ATT no v0.1.0 (sem IDFA, sem tracking).
- Haptics via `Core Haptics` quando disponível, com fallback para `UIImpactFeedbackGenerator`.

## Armadilhas conhecidas

| Problema | Mitigação |
|---|---|
| Safe area (notch / Dynamic Island / home indicator) | mesmo `SafeAreaContainer` do Android; testado no maior e no menor aparelho |
| ProMotion 120 Hz | `Engine.max_fps` segue o painel; simulação fixa a 60 Hz |
| Gesto de home na borda inferior | nada interativo nos últimos 20 pt |
| Suspensão agressiva do app | salvar em `NOTIFICATION_APPLICATION_PAUSED` sem exceção |
| Áudio interrompido por ligação | categoria de sessão correta e retomada limpa |
| Revisão da App Store | sem conteúdo de placeholder, sem tela de debug, sem link quebrado |

## Build

```bash
./tools/ci/build_ios.sh          # exporta projeto Xcode
./tools/ci/archive_ios.sh        # xcodebuild archive + export IPA
```

## Loja (GSD 22)

Ícone 1024×1024 sem canal alfa, screenshots 6,7" e 5,5" (obrigatórios) + iPad se suportado,
texto promocional, descrição, palavras-chave, política de privacidade, faixa etária,
build no TestFlight validado antes de submeter.

## Provisioning
- Requires an Apple Developer Account.
- Certificates and Provisioning Profiles should be loaded onto the CI runner (macOS).

## Scripts
- `build_ios.sh`: Exports the Xcode project from Godot.
- `archive_ios.sh`: Runs `xcodebuild` to archive and export the IPA.
