# Matriz de dispositivos

> Testar em "um Android" não é testar em Android. A matriz existe para tornar a cobertura
> explícita e para dar um alvo numérico de performance.

## Níveis (tiers)

| Tier | Definição | Preset de qualidade | Alvo |
|---|---|---|---|
| **Low** | 2–3 GB RAM, GPU antiga, GLES3 | `Low` | 60 FPS estáveis com efeitos reduzidos |
| **Mid** | 4–6 GB RAM, Vulkan, 60–90 Hz | `Medium` | **60 FPS — este é o aparelho de referência** |
| **High** | ≥ 8 GB RAM, 120 Hz | `High` | 120 FPS com todos os efeitos |

O aparelho **Mid** é o juiz. Todo orçamento de performance é escrito contra ele.

## Cobertura mínima antes de cada marco

| Marco | Cobertura |
|---|---|
| MVP | 1 Android Mid (físico) |
| Alpha | 2 Android (Low + Mid) + 1 iPhone |
| Beta | 4 Android (Low, Mid, High, tablet) + 3 iPhone (mín. suportado, atual, Pro) + 1 iPad |
| Release | tudo acima + teste de compatibilidade em nuvem cobrindo ≥ 20 modelos |

## Proporções obrigatórias

| Proporção | Onde aparece | Cuidado principal |
|---|---|---|
| 16:9 | tablets, Android antigo | HUD não pode "esticar" nem sobrar espaço morto |
| 18:9 | Android comum | baseline |
| 19,5:9 | iPhone com notch | safe area superior |
| 20:9 | Android moderno alto | campo de jogo mais alto — câmera precisa compensar |
| 4:3 / 3:2 | iPad | UI reflui, o Field ganha margem; não esticar |

Todas verificadas com capturas automáticas em `tools/dev/screenshot_matrix.sh` (GSD 20).

## Checklist por aparelho

```text
[ ] Boot < 3 s até o menu (cold start)
[ ] 60 FPS em partida cheia (8 Runners, Mega Seal, todos os efeitos do preset)
[ ] Sem hitch > 50 ms durante 3 min de partida
[ ] Memória estável (sem crescimento após 10 partidas seguidas)
[ ] Safe area correta em todas as telas
[ ] Toque responsivo nos cantos e sob o notch
[ ] Áudio sem estouro nem latência perceptível
[ ] Háptico funcionando (ou degradando silenciosamente)
[ ] Back / gesto de voltar comportado
[ ] Rotação bloqueada
[ ] Bateria: < 8 %/hora em partida contínua no preset padrão
```

## Registro

Resultados por aparelho e por versão ficam em `docs/performance/device-results.md`
(criado na primeira medição real, em GSD 02).
