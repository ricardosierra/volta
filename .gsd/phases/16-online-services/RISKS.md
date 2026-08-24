# GSD 16 — Riscos da fase

| # | Risco | P | I | Mitigação |
|---|---|---|---|---|
| F16-01 | Rede começar a bloquear gameplay sutilmente | 3 | 5 | nenhuma chamada no caminho de simulação; bateria de cenários de rede como critério de aceite |
| F16-02 | Cloud save perder progresso local | 2 | 5 | reconciliação monotônica; teste de conflito nos dois sentidos; nunca sobrescrever sem regra |
| F16-03 | Fila offline duplicar submissões | 3 | 3 | idempotência ponta a ponta; teste com app morto no meio |
| F16-04 | Boot ficar mais lento por causa de rede | 3 | 3 | config e perfil buscados de forma assíncrona, com embutido como padrão |
| F16-05 | Remote config quebrar o jogo em produção | 2 | 5 | validação de faixa no cliente **e** no servidor; nunca aplica em partida; fallback embutido |
| F16-06 | Erro de rede virar popup irritante | 3 | 2 | política explícita: no máximo um ícone discreto no menu |

## Riscos globais tocados
- **RISK-011** (backend indisponível) é resolvido aqui, por construção.
