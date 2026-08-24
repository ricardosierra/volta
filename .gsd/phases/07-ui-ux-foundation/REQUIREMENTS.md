# GSD 07 — Requisitos

## Funcionais

| # | Requisito | Verificação |
|---|---|---|
| R07-01 | Todos os tokens vivem em `Resource` e nenhum componente conhece hex ou pixel mágico | inspeção + lint |
| R07-02 | 12 componentes implementados, com todos os estados | showcase |
| R07-03 | `SafeAreaContainer` envolve toda tela e reage a mudança em runtime | teste em aparelho com notch |
| R07-04 | Navegação com pilha; back físico e gesto fazem a coisa óbvia | manual Android + iOS |
| R07-05 | Transições de 250 ms que nunca bloqueiam o toque | manual |
| R07-06 | Settings persistem e têm efeito imediato | teste + manual |
| R07-07 | Test drive de controles funciona ao vivo na tela de settings | manual |
| R07-08 | Nenhum texto hardcoded: tudo por chave de tradução | `validate-repo.sh` |
| R07-09 | en e pt-BR completos, sem chave faltando | script de verificação |
| R07-10 | Onboarding de 6 passos, cada um saindo ao ser demonstrado | teste + playtest |
| R07-11 | Primeira execução vai direto para a partida, pulando o menu | teste |
| R07-12 | Layout correto em 16:9, 18:9, 19,5:9, 20:9 e tablet | capturas automáticas |
| R07-13 | Escala de UI 0,9–1,25 sem sobreposição | capturas em 1,25 |
| R07-14 | Alvo de toque ≥ 48 dp em toda a UI | inspeção + script |
| R07-15 | Profundidade de navegação máxima 2 a partir do menu | inspeção |
| R07-16 | Menu principal com PLAY como maior alvo de toque | inspeção |

## Não funcionais

| # | Requisito | Alvo |
|---|---|---|
| N07-01 | Splash até o menu | < 1,5 s |
| N07-02 | Troca de tela | < 300 ms |
| N07-03 | UI custa | < 0,8 ms de CPU/frame |
| N07-04 | Nenhuma tela carrega mais de 300 ms sem mostrar algo | manual |
| N07-05 | Estado da tela sobrevive a pause/resume do sistema | teste |
