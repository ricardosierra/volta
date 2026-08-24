# GSD 01 — Riscos da fase

| # | Risco | P | I | Mitigação |
|---|---|---|---|---|
| F01-01 | Export templates da 4.3 não instalados ou indisponíveis offline | 3 | 4 | `REPO-001` verifica antes de qualquer outra coisa; passo de instalação documentado; se faltar, a fase para em REPO-012 e o resto segue |
| F01-02 | Build Android falha por JDK/SDK ausente | 3 | 3 | `tools/dev/doctor.sh` valida o ambiente e dá instrução exata; PlayTable neste mesmo ambiente já usa JDK 17 |
| F01-03 | Godot no CI ficar lento ou instável (download a cada run) | 2 | 3 | cache do runner por versão; se piorar, imagem própria |
| F01-04 | Verificadores gerando falso positivo e virando ruído | 3 | 2 | cada regra tem teste positivo **e** negativo; regra que gera ruído é ajustada, nunca desativada silenciosamente |
| F01-05 | GUT quebrar com a versão da engine | 2 | 3 | versão do GUT pinada; isolado em `addons/`; se quebrar, avaliar GdUnit4 (novo ADR) |
| F01-06 | Fase inchar com "já que estou aqui" (design system, câmera, entrada) | 3 | 3 | escopo negativo explícito no README; ideia nova vai para o `BACKLOG.md` |
| F01-07 | Não haver aparelho Android disponível para REPO-012 | 2 | 3 | tarefa marcada como bloqueante do gate; se faltar aparelho, a fase fecha com pendência **explícita** em `STATUS.md`, e a GSD 02 não pode fechar sem ela |

## Riscos globais tocados

- **RISK-009** (perda de save): `REPO-007` entrega a base de resiliência já na fase 01.
- **RISK-020** (perda de contexto entre sessões): `HANDOFF.md` + `STATUS.md` viram hábito aqui.
