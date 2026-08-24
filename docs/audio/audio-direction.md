# Direção de áudio

> O jogador precisa saber que capturou, que matou, que morreu e que está em perigo **sem olhar
> a HUD**. Áudio é informação antes de ser estética.

## Estética

Sintetizadores limpos, graves redondos, percussão eletrônica seca, transientes curtos. Nada de
instrumento acústico, nada de voz, nada de trilha "épica orquestral". A referência sonora é a
mesma da arte: energia elétrica contida.

## Música adaptativa por camadas

Uma faixa por arena, montada em camadas que entram e saem por crossfade curto (0,4 s), sempre
sincronizadas ao compasso — nunca cortando no meio da batida.

| Camada | Entra quando |
|---|---|
| `base` | sempre (baixo + pulso) |
| `rhythm` | jogador sai do Claim pela primeira vez |
| `tension` | Arc longo (risco ≥ 1,8×) ou inimigo perto do seu Arc |
| `melody` | território ≥ 25 % |
| `surge` | Surge ≥ 3 |
| `push` | Final Push (últimos 30 s) — muda a harmonia, não só o volume |

O ritmo da música dirige o pulso do grid do fundo (ver `art/vfx.md`) — imagem e som pulsam juntos.

## SFX

| Evento | Caráter |
|---|---|
| Sair do Claim | *whoosh* grave e curto |
| Arc crescendo | drone quase inaudível que sobe de tom com o comprimento |
| Seal pequeno | acorde curto ascendente |
| Seal médio | acorde + *swell* |
| Mega Seal | acorde cheio com cauda e sub-grave |
| Roubo de território | camada extra de "quebra de vidro" no Seal |
| Break (você mata) | impacto seco + reverb curto |
| Sua morte | corte súbito de tudo + tom descendente (o silêncio é o efeito) |
| Backwash | curto-circuito |
| Overload (aviso) | três ticks agudos |
| Surge sobe | nota da escala, uma por nível — sobe junto com o combo |
| Power-up | jingle curto e único por tipo |
| Countdown | três ticks + nota de largada |
| Final Push | risco ascendente + mudança de camada |
| Vitória / Derrota | fanfarra curta / acorde suspenso |
| UI: toque, voltar, abrir, comprar | cliques curtos, distintos, jamais irritantes |

**Anti-fadiga:** todo SFX repetitivo tem 3–4 variações e leve randomização de tom (±3 %).
Sons simultâneos do mesmo tipo são limitados (máx. 3), com prioridade — captura sempre vence
ambiente.

## Mixagem

| Barramento | Padrão | Observações |
|---|---|---|
| `Master` | 100 % | |
| `Music` | 70 % | duck de −4 dB por 0,3 s em Break e Mega Seal |
| `SFX` | 100 % | |
| `UI` | 80 % | sub-barramento de SFX |

- Limitador no master para não estourar em alto-falante de celular.
- Toda a mixagem é validada **no alto-falante do telefone**, não em fone de estúdio.
- Áudio pausa junto com a simulação e retoma sem estalo.
- Respeita o botão físico de silencioso e interrupções do sistema (ligação, alarme).

## Formato e orçamento

| Item | Regra |
|---|---|
| Música | OGG Vorbis, ~112 kbps, mono para camadas de apoio |
| SFX | OGG curto, 44,1 kHz, mono |
| Orçamento de tamanho | ≤ 12 MB para todo o áudio no v0.1.0 |
| Vozes simultâneas | ≤ 16 |
| Latência-alvo | < 60 ms do evento ao som |

## Configurações

`Settings > Audio`: Master · Music · SFX (sliders independentes) + `Reduzir sons intensos`
(acessibilidade: limita picos e desliga o sub-grave do Mega Seal).

## Implementação por fase

| Fase | Entrega |
|---|---|
| GSD 07 | barramentos, sons de UI, controles de volume |
| GSD 09 | SFX de gameplay completo + háptico sincronizado |
| GSD 09 | música adaptativa por camadas |
| GSD 13 | faixa por arena |
| GSD 19 | otimização de memória e streaming |
