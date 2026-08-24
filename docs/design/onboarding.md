# Onboarding

> Nenhum jogador vai ler 15 telas para aprender um jogo que se explica com um dedo.
> Todo o ensino acontece **dentro** do gameplay, na primeira partida.

## Princípios

1. **Ensinar fazendo.** Nenhuma dica que não possa ser executada imediatamente.
2. **Uma coisa por vez.** Nunca duas instruções na tela.
3. **Some ao entender.** A dica desaparece assim que o jogador demonstra o comportamento,
   não depois de um timer.
4. **Sem paredes.** Não existe "toque aqui para continuar", nem tela bloqueada, nem seta forçada.
5. **Primeira partida é fácil de propósito.** 2 bots `Grazer` no nível Rookie, arena pequena.
   O jogador precisa **ganhar** a primeira, e não perceber que foi ajudado.

## Sequência

| # | Gatilho | Texto | Sai quando |
|---|---|---|---|
| 1 | Partida começa | **"Deslize para mover"** | primeiro swipe reconhecido |
| 2 | 2 s após o passo 1 | **"Saia do seu território"** | o Arc começa |
| 3 | Arc com ≥ 8 células | **"Volte para capturar"** | primeiro Seal |
| 4 | 1º Seal | *(sem texto)* celebração exagerada + `+X%` | — |
| 5 | Bot inimigo desenhando a < 20 células | **"Corte o arco inimigo"** | primeiro Break, ou 25 s |
| 6 | Jogador sofre Backwash | **"Você tocou seu próprio arco"** | próximo Seal |
| 7 | Fim da partida | Resultado + primeiro Rank + 1 desbloqueio garantido | — |

Cada passo é um `TutorialStepResource` com: gatilho, texto, condição de saída, evento de
analytics. Adicionar ou remover passo é **dado**, não código.

## Regras de apresentação

- Texto centralizado na metade superior, fora do polegar, fonte grande, alto contraste.
- Entra em 0,15 s, sai em 0,2 s. Nunca pisca.
- Um leve halo indica o alvo (ex.: a borda do próprio Claim no passo 2) — sem seta agressiva.
- Instrução nunca aparece durante `DrawingTrail` com inimigo a menos de 10 células: não se
  ensina no meio de um susto.

## Estado e repetição

- Progresso salvo em `save.tutorial` com `schema_version` (ver `architecture/save-system.md`).
- Jogador pode repetir em `Settings > Tutorial > Rejogar introdução`.
- Se o jogador desinstalar e voltar, o tutorial roda de novo — mas os passos que ele já
  concluiu na sessão anterior (quando há cloud save) são pulados.

## Segunda camada (ensino contínuo)

Depois da primeira partida, o ensino continua sem tutorial:

| Conceito | Como é ensinado |
|---|---|
| Risco vale pontos | multiplicador na HUD sobe visivelmente enquanto o Arc cresce |
| Roubar vale mais | células roubadas brilham diferente ao serem capturadas |
| Surge existe | medidor aparece na primeira vez que encadeia dois Seals |
| Overload | aviso 2 s antes, com texto único **"Arco longo demais"** |
| Power-ups | primeiro orbe coletado mostra o nome e o efeito por 1,5 s |

## Métricas de sucesso (gate da Alpha)

| Métrica | Alvo |
|---|---|
| Tempo até o 1º Seal | < 25 s para ≥ 80 % dos novos |
| Conclusão da 1ª partida | ≥ 90 % |
| Passos do tutorial concluídos | ≥ 85 % chegam ao passo 5 |
| Jogadores que iniciam a 2ª partida | ≥ 70 % |

Se qualquer uma falhar no playtest, o onboarding é refeito **antes** de seguir para Beta.
