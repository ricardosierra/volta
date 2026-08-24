# GSD 21 — Requisitos

| # | Requisito | Verificação |
|---|---|---|
| R21-01 | AAB assinado gerado pelo CI, reprodutível | build |
| R21-02 | `minSdk` 24, `targetSdk` conforme exigência atual | manifest |
| R21-03 | arm64-v8a + armeabi-v7a | análise do bundle |
| R21-04 | **Nenhuma** ferramenta de debug na build | inspeção + verificação de export |
| R21-05 | Nenhuma cena de debug incluída no export | `check_release_build.sh` |
| R21-06 | Ícone adaptativo correto em máscara circular, squircle e quadrada | dispositivo |
| R21-07 | Splash com cor do tema e logo vetorial | dispositivo |
| R21-08 | Permissões mínimas e justificadas | manifest |
| R21-09 | `versionCode` monotônico derivado do semver | build |
| R21-10 | Tamanho de download ≤ 60 MB | Play Console |
| R21-11 | Data Safety coerente com a coleta real | revisão cruzada com GSD 18 |
| R21-12 | Política de privacidade publicada e acessível no app | link |
| R21-13 | Botão voltar do Android correto em toda tela | manual |
| R21-14 | Assets de loja completos (en + pt-BR) | checklist |
| R21-15 | Teste interno instalado e jogado por 3 pessoas | relatório |
