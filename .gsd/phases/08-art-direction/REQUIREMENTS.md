# GSD 08 — Requisitos

## Funcionais

| # | Requisito | Verificação |
|---|---|---|
| R08-01 | Nenhum `PLACEHOLDER-ART-*` sobrevive | `validate-repo.sh` |
| R08-02 | Fonte definitiva, licenciada, com subconjunto latino estendido | `assets/CREDITS.md` |
| R08-03 | 8 temas implementados, todos passando na verificação de contraste | script |
| R08-04 | Cores de jogador com separação de matiz ≥ 40° em todos os temas | script |
| R08-05 | Identificação por **cor + forma + padrão** | jogável no tema Monochrome |
| R08-06 | Hierarquia visual respeitada (Runner > Arc > borda > preenchimento > fundo) | revisão |
| R08-07 | Glow do Arc proporcional ao comprimento | manual + inspeção |
| R08-08 | Células roubadas têm efeito visual distinto (`Steal Shatter`) | manual |
| R08-09 | Ícone do app, logo e wordmark prontos em todas as densidades | inspeção |
| R08-10 | Presets de qualidade alteram efeitos conforme a tabela de `art/vfx.md` | manual em 3 presets |
| R08-11 | Preset `Auto` escolhe corretamente por classe de dispositivo | teste em Low e High |
| R08-12 | Todo asset é vetorial ou procedural; nenhuma textura > 1024² | inspeção |
| R08-13 | Nenhum asset de terceiros sem licença registrada | `assets/CREDITS.md` + CI |

## Não funcionais

| # | Requisito | Alvo |
|---|---|---|
| N08-01 | VFX de gameplay | < 2,0 ms de GPU no Mid, preset Medium |
| N08-02 | Draw calls | ≤ 40 (Low) · 80 (Medium) · 120 (High) |
| N08-03 | Texturas | ≤ 24 MB |
| N08-04 | 60 FPS mantidos com todos os efeitos do preset padrão | dispositivo |
| N08-05 | Jogo legível e satisfatório no preset Low | playtest |
