# Diagramas

Fontes em Mermaid (`.mmd`), versionadas. Exportações (PNG/SVG) vão para `assets/exported/diagrams/`
e **não** são versionadas — são geradas por `tools/dev/render_diagrams.sh`.

| Arquivo | Conteúdo | Aparece em |
|---|---|---|
| `runner-fsm.mmd` | Máquina de estados do Runner | `architecture/state-machines.md` |
| `game-fsm.mmd` | Máquina de estados do jogo | `architecture/state-machines.md` |
| `architecture-layers.mmd` | Camadas e regra de dependência | `architecture/overview.md` |
| `seal-flow.mmd` | Passo a passo de um Seal | `architecture/territory-system.md` |
| `screen-flow.mmd` | Navegação entre telas | `ui/screens.md` |
| `gsd-dependencies.mmd` | Dependências entre fases | `.gsd/DEPENDENCIES.md` |

Diagramas inline em Markdown continuam permitidos (e preferidos) para coisas pequenas. Este
diretório é para os que aparecem em mais de um lugar.
