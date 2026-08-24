# GSD 08 — Critérios de aceite

| # | Critério | Como verificar |
|---|---|---|
| A08-01 | **Zero `PLACEHOLDER-ART-*` no repositório** | `validate-repo.sh` |
| A08-02 | Fonte definitiva com licença registrada | `assets/CREDITS.md` |
| A08-03 | 8 temas passam no verificador de contraste e de matiz | script no CI |
| A08-04 | `Monochrome` é jogável só por forma e padrão | playtest |
| A08-05 | Hierarquia visual respeitada em todos os temas e presets | auditoria ART-010 |
| A08-06 | Teste cego "onde está a ameaça?" ≥ 90 % de acerto | 10 capturas, 5 pessoas |
| A08-07 | Glow do Arc comunica risco sem número | manual |
| A08-08 | Roubo de célula é visualmente distinto | manual |
| A08-09 | Animação de Seal proporcional ao tamanho | manual |
| A08-10 | Presets de qualidade funcionam; `Auto` acerta | teste em Low e High |
| A08-11 | VFX < 2,0 ms de GPU no Mid, preset Medium | profiler |
| A08-12 | Draw calls dentro do teto por preset | monitor |
| A08-13 | Texturas ≤ 24 MB; nenhuma > 1024² | inspeção |
| A08-14 | 60 FPS no Mid com preset Medium, partida cheia | dispositivo |
| A08-15 | Nenhum asset de terceiros sem licença | CI |
| A08-16 | Nenhuma semelhança com identidade visual de terceiros | revisão |

## Teste "não parece protótipo"

Mostrar 3 capturas e 1 vídeo de 20 s a 5 pessoas que não conhecem o projeto:
*"isso parece um jogo publicado ou um projeto de estudante?"*.
**Menos de 4 de 5 respostas "publicado" reprova a fase.** É subjetivo, e é exatamente o
critério que importa aqui.
