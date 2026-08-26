# Android

Plataforma **primária**. Se algo funciona no iOS mas não no Android, é bug de prioridade alta.

## Alvo

| | |
|---|---|
| `minSdk` | 24 (Android 7.0) |
| `targetSdk` | 34 (exigência atual do Play; revisar antes de cada release) |
| ABIs | `arm64-v8a` (principal) + `armeabi-v7a` (compatibilidade) |
| Formato | **AAB** para o Play; APK só para teste interno |
| Renderer | `Mobile` (Vulkan quando disponível) com fallback `Compatibility` (GLES3) |
| Orientação | portrait travado |
| Package | `com.ricardosierra.volta` |

## Permissões

Nenhuma no v0.1.0. Sem `INTERNET` até GSD 16 — e quando entrar, entra sozinha.
Sem armazenamento externo, sem localização, sem contatos, sem identificadores de publicidade.

> Toda permissão nova exige justificativa no PR e atualização do formulário de Data Safety.

## Preparação (GSD 21)

1. Export template 4.3 stable instalado (mesma build do CI).
2. `keystore` de release gerado e guardado **fora do repositório** (senhas em `.env` local e
   nos secrets do GitHub Actions).
3. `export_presets.cfg` não é versionado; é gerado por `tools/ci/make_export_presets.sh` a
   partir de um template + variáveis de ambiente.
4. Ícones adaptativos: foreground + background separados, testado em máscara circular,
   squircle e quadrada.
5. Splash: cor de fundo do tema + logo vetorial; **sem** tela de carregamento longa.
6. `versionCode` = inteiro monotônico gerado do semver (`major*10000 + minor*100 + patch`).

## Build

```bash
./tools/ci/build_android.sh debug     # APK para teste
./tools/ci/build_android.sh release   # AAB assinado
```

O script valida antes de exportar: versão do Godot, `VOLTA_DEBUG_TOOLS=false`, ausência de
cenas de debug, presença de todos os ícones, tamanho do bundle abaixo do teto.

## Performance

- Alvo: **60 FPS** no aparelho de referência intermediário; 120 FPS onde o painel permitir.
- `Engine.max_fps` segue a taxa do painel; a simulação continua a 60 Hz fixo (ADR-0014).
- Vsync ligado; `low_processor_mode` no menu para poupar bateria.
- Texturas em ETC2/ASTC; nada de PNG cru em runtime.
- Orçamento de memória: ver [`../performance/performance-budget.md`](../performance/performance-budget.md).

## Armadilhas conhecidas

| Problema | Mitigação |
|---|---|
| Notch e furo de câmera | safe area via `DisplayServer.get_display_safe_area()`, aplicada em `SafeAreaContainer` próprio |
| Gestos do sistema na borda inferior | HUD e botões respeitam margem inferior extra |
| Back button do Android | mapeado explicitamente: pausa na partida, volta no menu, confirma saída na raiz |
| App em background | salva imediatamente e pausa a simulação |
| Taxa variável (LTPO) | nunca assumir `delta` estável; simulação é fixa por definição |
| Aparelhos low-end com GLES3 | preset `Low` automático; glow e pós-processamento desligados |
| Teclado/IME abrindo sobre a UI | só existe input de texto no apelido; tela reposiciona |

## Loja (GSD 21)

Ícone 512×512, feature graphic 1024×500, ≥ 4 screenshots por tamanho de tela, vídeo opcional,
descrição curta e longa (en + pt-BR), política de privacidade publicada, formulário de Data
Safety, classificação etária e declaração de anúncios (a partir de GSD 25).

## Adaptive Icons
- Foreground: Transparent PNG (432x432)
- Background: Solid Color `#0D0D14`
- Rendered safely inside the 72dp mask.

## Explicit Permissions
- `INTERNET`: Required for backend API and Multiplayer telemetry.
- `VIBRATE`: Required for haptic feedback.
- **NO** external storage.
- **NO** precise location.
