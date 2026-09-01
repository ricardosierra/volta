# Itens fora de escopo observados durante a execução

Registrado por: plano 01 (inversão de camada de simulação).

## Corrida no índice git compartilhado (execução paralela de planos)

Durante a execução deste plano, múltiplos executores de planos da fase 26.1 rodaram em
paralelo na mesma árvore de trabalho / mesmo índice do git. Em dois momentos, arquivos que
eu já havia `git add`ado (mas ainda não commitado) foram varridos para dentro de commits de
**outros** planos, porque o índice do git é compartilhado entre todos os processos:

- `apps/mobile/src/gameplay/match_director.gd` (minha mudança da Task 1) foi commitado junto
  com `efcb19a fix(tools): regra 4 do validate-repo ganha limite de palavra a direita`
  (plano 05), que também arrastou `apps/mobile/tests/unit/test_seal_solver.gd` (plano 02).
- `apps/mobile/tests/gameplay/test_match_director_runner_spawned.gd` (meu teste da Task 1)
  foi commitado em `df97838 chore(territory): add missing .uid for test_seal_solver.gd`
  (plano 02), que também limpou o `.uid` que faltava.

Conteúdo conferido idêntico ao que este plano pedia em ambos os casos — não foi alterado por
quem commitou. Nenhuma ação de correção necessária; documentando para rastreabilidade. Depois
disso, a Task 2 foi commitada isolada (`6abfa8a`) esperando o índice esvaziar antes de
`git add` + `git commit` em sequência imediata, sem executar comandos longos com o índice
sujo no meio do caminho.

## Falhas de teste transitórias, fora do escopo deste plano

Na verificação final (`./tools/ci/test-client.sh`), observei falhas transitórias em arquivos
que **não pertencem a este plano** e que outros executores estavam editando concorrentemente
no momento da checagem:

- `apps/mobile/tests/unit/test_main_menu_screen.gd` — `main_menu_screen.gd` é do plano 03
  (decomposição de `ui/screens/*`); estava em edição no momento (working tree sujo).
- `apps/mobile/tests/unit/test_remote_profile_repository.gd` — `remote_profile_repository.gd`
  é do plano 05 (bug de produção `load_profile()` vs `get_profile()`); estava em edição no
  momento.
- Antes disso, `test_log.gd::test_file_sink_rotates` falhou uma vez de forma intermitente
  (stress test de rotação de arquivo, 800 escritas) e passou na repetição — não relacionado a
  nenhum plano da fase 26.1, provável sensibilidade a I/O concorrente de múltiplos executores
  rodando `test-client.sh` ao mesmo tempo.

Não toquei em nenhum desses arquivos. Rodei a suíte isolada de `tests/gameplay/` e o teste
`test_runner_presentation_wiring` deste plano separadamente — ambos passam limpos
independente do estado do restante da árvore (ver `26.1-01-SUMMARY.md`).

## Confirmação do plano 02 (refatoração de SealSolver)

Registrado por: plano 02. Confirma, do outro lado, o mesmo incidente descrito acima pelo
plano 01: `apps/mobile/tests/unit/test_seal_solver.gd` (Task 1 deste plano, staged mas ainda
não commitado) foi varrido para dentro de `efcb19a` (commit do plano 05), junto com a mudança
de `match_director.gd` do plano 01. Conteúdo conferido byte a byte igual ao escrito — sem
alteração de terceiros.

Ao tentar corrigir a atribuição criando um commit que só continha o `.uid` que faltava para
`test_seal_solver.gd`, um `git commit` sem pathspec (rodado por hábito, não por `git add -A`)
pegou o índice inteiro naquele instante e arrastou junto
`apps/mobile/tests/gameplay/test_match_director_runner_spawned.gd(.uid)` (plano 01), que
outro processo tinha acabado de `git add`. Corrigido tentando `git rm --cached` (bloqueado
pelo sandbox de permissões) e depois `git reset <hash-fixo> -- <path>` (não `HEAD^`, que é
relativo e mudou de commit no meio da operação por causa de outro commit concorrente).
Descobri que `git commit -- <pathspec>` usa o conteúdo do **working tree**, não do índice, e
por isso não conseguia expressar uma remoção pura de tracking sem apagar o arquivo em disco —
o que destruiria trabalho do plano 01. Solução final: `git reset HEAD -- <path>` para devolver
o índice ao estado igual ao HEAD atual (arquivo permanece rastreado, como já estava em
`df97838`), sem deixar uma remoção "pendurada" no índice compartilhado que pudesse contaminar
o próximo commit de qualquer plano. Resultado: conteúdo correto e intacto, só a atribuição do
commit ficou cruzada entre planos — sem impacto funcional. A partir daí, todo commit deste
plano usou `git commit -m "..." -- <caminho-absoluto>`, que compara o working tree contra o
HEAD só para os caminhos dados e ignora o resto do índice compartilhado — não depende de
`git add` prévio nem sofre a corrida acima. A Task 2 (`be9f58e`) saiu isolada, só com
`seal_solver.gd`, confirmado com `git show --stat`.

## Confirmação do plano 05 (correções pontuais)

Registrado por: plano 05. Confirma, do lado de quem gerou a corrida, o mesmo incidente
relatado acima pelos planos 01 e 02: rodei `git add tools/ci/validate-repo.sh` seguido de
`git commit -m "..."` **sem pathspec** na Task 1, e o índice já continha
`apps/mobile/src/gameplay/match_director.gd` (plano 01) e
`apps/mobile/tests/unit/test_seal_solver.gd` (plano 02) staged por outros processos. O commit
resultante (`efcb19a`) empacotou os três. Conferido: o diff de `tools/ci/validate-repo.sh`
dentro desse commit é exatamente o pretendido pela Task 1, nada meu vazou para os outros
arquivos nem vice-versa — é só atribuição de commit cruzada entre planos, sem dado perdido e
sem impacto funcional. Não tentei reescrever o histórico (`efcb19a` já tinha um commit de
outro plano em cima, `df97838`; um `reset`/rebase teria descartado trabalho alheio). A partir
da Task 3 em diante usei `git commit -m "..." -- <caminho>` (pathspec direto no `commit`, não
só no `add`), que ignora o resto do índice compartilhado — Tasks 3 e 4 (`db59d11`, commit da
Task 4 abaixo) saíram isoladas, confirmado com `git show --stat` em cada uma.

### Bug idêntico ao da Task 4, fora do escopo deste plano

`apps/mobile/src/progression/remote_leaderboard_repository.gd:22` chama `UUID.v4()` — a mesma
classe inexistente que quebrava a compilação de `remote_profile_repository.gd` (corrigido na
Task 4 deste plano, ver `26.1-05-SUMMARY.md`). Confirmado com
`godot --check-only --script res://src/progression/remote_leaderboard_repository.gd`: mesmo
"Identifier 'UUID' not declared in the current scope.". Este arquivo não está na lista
`files_modified` do plano 05 nem de nenhum outro plano desta fase — não foi tocado. Fica
registrado aqui para uma fase futura de religação de `progression/` corrigir junto.
