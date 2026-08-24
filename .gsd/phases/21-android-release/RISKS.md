# GSD 21 — Riscos da fase

| # | Risco | P | I | Mitigação |
|---|---|---|---|---|
| F21-01 | Ferramenta de debug vazar para produção | 2 | 5 | `check_release_build.sh` no workflow, com teste negativo |
| F21-02 | Keystore perdido | 2 | 5 | backup seguro fora do repositório, documentado; Play App Signing considerado |
| F21-03 | Data Safety divergir da coleta real | 3 | 4 | revisão cruzada com a auditoria da GSD 18 |
| F21-04 | Pendência de marca inviabilizar o nome (RISK-012) | 3 | 4 | H-01 tem prazo **antes** desta fase; nome isolado em tokens e strings para renomear barato |
| F21-05 | Conta do Play não estar pronta | 2 | 3 | H-02 mapeada com antecedência; a build fica pronta mesmo sem conta |
| F21-06 | Rejeição por metadado ou conteúdo | 2 | 3 | checklist de loja; teste interno antes de qualquer submissão pública |
