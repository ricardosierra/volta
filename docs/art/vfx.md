# VFX

> Todo efeito responde a três perguntas antes de existir: **o que ele comunica?**,
> **ele esconde alguma informação?**, **quanto custa em GPU?**. Se falhar em qualquer uma,
> não entra.

## Catálogo

| Efeito | Gatilho | Técnica | Custo-alvo 🎯 |
|---|---|---|---|
| **Seal Fill** | captura | shader de máscara radial sobre a textura de Claim | < 0,3 ms |
| **Seal Edge Sparks** | captura | `GPUParticles2D` ao longo do perímetro novo, pool | < 0,2 ms |
| **Steal Shatter** | célula roubada | shader com ruído: a cor antiga "quebra" antes de virar a nova | incluso no fill |
| **Arc Glow** | sempre que há Arc | shader no `MultiMesh`/`Line2D`, intensidade = f(comprimento) | < 0,2 ms |
| **Arc Overload** | Arc perto do limite | cintilação âmbar + ruído na cauda | < 0,1 ms |
| **Break Burst** | eliminação | explosão geométrica + onda de choque | < 0,4 ms (pico) |
| **Arc Dissolve** | morte | células do Arc somem em cascata a partir da origem | < 0,2 ms |
| **Backwash Leak** | auto-colisão | Arc "vaza" e escorre para fora | < 0,15 ms |
| **Runner Core** | sempre | shader de núcleo pulsante | desprezível |
| **Runner Trail** | movimento | rastro curtíssimo, `Line2D` com fade | < 0,1 ms |
| **Surge Aura** | Surge ≥ 1 | aura orbital, densidade por nível | < 0,3 ms no nível 6 |
| **Power-up Aura** | efeito ativo | anel colorido por tipo | < 0,1 ms |
| **Power-up Orb** | orbe no campo | forma girando com glow e halo pulsante | < 0,1 ms |
| **Threat Arrow** | inimigo perto do Arc | seta na borda da tela, opacidade por distância | UI, desprezível |
| **Final Push** | últimos 30 s | vinheta quente + pulso na moldura da HUD | < 0,1 ms |
| **Ambient Motes** | sempre | partículas lentas e raras no fundo | < 0,1 ms |
| **Grid Pulse** | ritmo da música | shader do fundo | desprezível |

**Orçamento total de VFX: < 2,0 ms de GPU por frame** no aparelho Mid, preset Medium.

## Escala por preset de qualidade

| Efeito | Low | Medium | High |
|---|---|---|---|
| Seal Fill | sem máscara animada (fade simples) | completo | completo + faíscas extras |
| Seal Edge Sparks | ❌ | 40 partículas | 120 partículas |
| Break Burst | forma simples | completo | completo + onda de choque |
| Surge Aura | só cor | aura | aura + órbitas |
| Ambient Motes | ❌ | 20 | 60 |
| Glow (pós-processamento) | ❌ | leve | completo |
| Grid Pulse | estático | pulso | pulso + distorção |

O jogo precisa continuar **legível e satisfatório** no preset Low. Low não é castigo.

## Regras técnicas

1. **Pool obrigatório.** Nenhum `GPUParticles2D` é instanciado durante a partida.
2. **Um material por tipo**, com parâmetros por instância — para não quebrar o batching.
3. Nenhum efeito lê o grid por célula na CPU. O que precisa do grid usa a textura de Claim.
4. Todo efeito tem duração máxima e limpeza garantida (nada acumula ao longo da partida).
5. Todo efeito respeita `Settings > Reduce flashes` e `Reduce shake`.
6. Todo shader novo entra no orçamento e é medido em dispositivo real antes do merge.
7. Nenhum efeito desenha por cima da HUD, exceto o flash de vitória.

## Efeitos de Seal cosméticos (GSD 11)

Variações **puramente visuais** do Seal Fill, vendidas como cosmético premium: `Ripple`,
`Shatter`, `Bloom`, `Pixelate`, `Ink`. Todos com o mesmo custo-alvo e a mesma duração — nenhum
pode dar vantagem de leitura nem esconder informação do adversário.
