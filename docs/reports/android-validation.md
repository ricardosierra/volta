# Android Release Validation

> **Status: NÃO EXECUTADO.** Revisado em 2026-08-31 durante a auditoria das fases 10–25.
> A versão anterior deste arquivo afirmava resultados de teste que não aconteceram. O texto
> abaixo substitui aquelas afirmações pelo estado verificável do repositório.

## Por que este relatório foi reescrito

A versão anterior declarava testes em quatro aparelhos físicos (Galaxy A10, Pixel 4a, Galaxy
S23, Galaxy Tab S8), upload bem-sucedido ao Play Console, pacote abaixo de 50 MB e
"crash-free rate 100%", concluindo "Release Candidate is GO for Android Launch".

Nada disso podia ter acontecido:

- `tools/ci/build_android.sh:27-29` — o ramo `release` do script é
  `echo "build de release é GSD 21 (ANDR-001..003) — não implementado nesta fase." >&2; exit 1`.
  **Não existe build de release.** Sem AAB, não há o que subir ao Play Console.
- `.planning/STATE.md`, seção *Blockers/Concerns* — o gate F01-07 registra que nenhum Android
  físico foi conectado (`adb devices` vazio em 2026-08-25) e que a linha da Phase 1 em
  `docs/performance/device-results.md` continua pendente.
- Sem aparelho e sem build de release, não há origem possível para números de FPS por tier,
  tamanho de pacote ou taxa de crash.

## O que está de fato verificado

| Item | Estado | Evidência |
|---|---|---|
| Build de debug (APK) | Gerado ao menos uma vez | `dist/android/volta-debug.apk` (Plano 01-10) |
| Build de release (AAB) | **Não implementado** | `tools/ci/build_android.sh:27-29` |
| Assinatura de release | Não configurada | sem keystore referenciado no preset |
| Teste em aparelho físico | **Nunca executado** | gate F01-07 aberto em `STATE.md` |
| Upload ao Play Console | **Nunca executado** | depende do AAB, que não existe |
| Matriz Low/Mid/High | **Sem medição** | `docs/performance/device-results.md` pendente |

## O que falta para validar de verdade

1. Implementar o ramo `release` de `tools/ci/build_android.sh` (AAB assinado).
2. Configurar keystore e assinatura fora do repositório (nunca em `export_presets.cfg` — o
   secret-scan da CI barra).
3. Conectar um Android de tier Mid, instalar o APK/AAB e seguir o roteiro de
   `.planning/phases/01-repository-foundation/01-11-PLAN.md` Task 2.
4. Preencher `docs/performance/device-results.md` com números medidos, não estimados.
5. Só então avaliar upload a uma faixa de teste interno.

Enquanto os cinco itens acima não forem cumpridos, **não há parecer de GO para Android**.
