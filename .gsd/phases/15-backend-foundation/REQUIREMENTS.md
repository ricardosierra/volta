# GSD 15 — Requisitos

## Funcionais

| # | Requisito | Verificação |
|---|---|---|
| R15-01 | Conta anônima por dispositivo, sem e-mail | teste Pest |
| R15-02 | Token com escopo e rotação; refresh invalida o anterior | teste |
| R15-03 | Perfil consultável e editável (apelido, título, avatar) | teste |
| R15-04 | Submissão de partida **recalcula** o score no servidor | teste |
| R15-05 | Validação de plausibilidade conforme `anti-cheat.md` | 8 testes de limite |
| R15-06 | Leaderboards nas 4 janelas, com posição e vizinhança | teste |
| R15-07 | Cloud save com resolução de conflito e 3 versões guardadas | teste |
| R15-08 | Desafios diários iguais para todos, rotacionados por job | teste |
| R15-09 | Remote config com ETag, faixas validadas e sem chave nova | teste |
| R15-10 | Toda escrita é idempotente (`Idempotency-Key`) | teste |
| R15-11 | Rate limit por rota e por jogador | teste |
| R15-12 | Apelido sanitizado (bloqueio + normalização Unicode) | teste |
| R15-13 | Nenhuma rota sem validação por FormRequest | inspeção + teste |
| R15-14 | Migrações reversíveis | teste |
| R15-15 | Backup e restauração testados | procedimento executado |

## Não funcionais

| Requisito | Alvo |
|---|---|
| p95 de resposta | < 200 ms |
| Leaderboard (leitura) | < 50 ms via Redis |
| Pint e PHPStan nível 6+ | limpos |
| Cobertura Pest nas rotas críticas | ≥ 85 % |
| Nenhum segredo no repositório | CI |
