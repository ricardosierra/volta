# tools/

Scripts de CI, desenvolvimento e benchmark. **Regra:** todo script usado pelo CI precisa rodar
igual na máquina de qualquer pessoa. Se só funciona no runner, é armadilha.

| Script | O que faz | Criado em |
|---|---|---|
| `ci/validate-repo.sh` | estrutura, nomes proibidos, TODO/mock/placeholder, links | ✅ GSD 00 |
| `ci/check_links.sh` | links relativos quebrados em `docs/` e `.gsd/` | ✅ GSD 00 |
| `ci/lint.sh` | lint de GDScript + markdown | GSD 01 / REPO-010 |
| `ci/test-client.sh` | GUT headless (unit + integration + gameplay) | ✅ GSD 01 / REPO-006 |
| `ci/setup_godot.sh` | baixa a versão de `.godot-version` + export templates | ✅ GSD 01 / REPO-011 |
| `ci/check_layering.gd` | regra de dependência entre camadas | GSD 01 / REPO-009 |
| `ci/make_export_presets.sh` | gera `export_presets.cfg` a partir de template | GSD 01 / REPO-012 |
| `ci/build_android.sh` | APK de debug / AAB de release | GSD 01 / REPO-012 |
| `ci/build_ios.sh`, `ci/archive_ios.sh` | projeto Xcode e IPA | GSD 22 |
| `ci/check_release_build.sh` | garante que nada de debug entra no release | GSD 21 / ANDR-003 |
| `ci/check_contrast.gd` | contraste e separação de matiz dos temas | GSD 08 / ART-006 |
| `ci/check_i18n.sh` | chave faltando, chave órfã, texto solto | GSD 07 / UIUX-006 |
| `dev/doctor.sh` | valida o ambiente de desenvolvimento | ✅ GSD 00 |
| `dev/simulate.sh` | N partidas headless com invariantes | GSD 03 / TERR-014 |
| `dev/sync_config.sh` | sincroniza `packages/shared/config` → projeto | GSD 01 / REPO-005 |
| `dev/screenshot_matrix.sh` | capturas em todas as proporções | GSD 07 / UIUX-002 |
| `dev/latency_test.gd` | mede latência toque → direção | GSD 02 / MOVE-010 |
| `dev/economy_sim.php` | simula 30 dias de economia | GSD 10 / PROG-010 |
| `dev/render_diagrams.sh` | Mermaid → PNG/SVG | quando necessário |
| `benchmarks/territory_bench.gd` | os 15 benchmarks B01–B15 | GSD 03 / TERR-013 |

Scripts ainda não criados **não existem** neste repositório — não são stubs silenciosos.
