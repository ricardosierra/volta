# GSD 21 — Critérios de aceite

| # | Critério | Como verificar |
|---|---|---|
| A21-01 | AAB assinado gerado pelo CI | workflow |
| A21-02 | Nenhuma ferramenta ou cena de debug na build | `check_release_build.sh` |
| A21-03 | Ícone correto nas três máscaras | dispositivo |
| A21-04 | Splash correto, sem carregamento longo | dispositivo |
| A21-05 | Permissões mínimas | manifest |
| A21-06 | Data Safety coerente com a coleta real | revisão cruzada |
| A21-07 | Política de privacidade publicada e ligada no app | link |
| A21-08 | Download ≤ 60 MB | Play Console |
| A21-09 | Back button correto em toda tela | manual |
| A21-10 | Assets de loja completos em en e pt-BR | checklist |
| A21-11 | Validado em Low, Mid, High e tablet com build de release | matriz |
| A21-12 | Teste interno jogado por ≥ 3 pessoas, sem bloqueador | relatório |
| A21-13 | Nenhuma senha ou segredo em log de build | inspeção |
