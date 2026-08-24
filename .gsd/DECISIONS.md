# Decisões

## 1. Decisões arquiteturais (ADRs formais)

Todas aceitas em 2026-08-24, na GSD 00. Documento completo em [`../docs/decisions/`](../docs/decisions/).

| ADR | Decisão | Em uma linha |
|---|---|---|
| 0001 | **Godot 4.3 stable + GDScript tipado** | Iteração rápida, headless para testes, export mobile pronto; upgrade avaliado na GSD 20 |
| 0002 | **Grid denso + flood fill do exterior** | O(1) por célula, captura local, determinístico, 1 draw call |
| 0003 | **JSON versionado + escrita atômica + migrações encadeadas** | Nunca perder progresso; depurável |
| 0004 | **Laravel 11 + PostgreSQL + Redis** | Produtividade e ecossistema; leaderboard em ZSET |
| 0005 | **Servidor autoritativo em Godot headless** | Mesma simulação nos dois lados: impossível divergir no território |
| 0006 | **Ângulo livre com taxa de giro + buffer de input** | Fluidez mobile; Arc rasterizado 4-conectado |
| 0007 | **Auto-colisão = Backwash, não morte** | Morte sempre tem culpado; lista de causas de morte fechada |
| 0008 | **IA por utilidade com perfis em dados** | Personalidade é `.tres`; dificuldade por comportamento, nunca por velocidade |
| 0009 | **Control nativo + design system em tokens** | Um lugar para mudar a aparência inteira; sem dependência externa |
| 0010 | **Analytics por interface + adapters** | Nenhum SDK dentro do gameplay; privacidade auditável |
| 0011 | **Tema como Resource; cosmético é dado** | Acessibilidade e monetização pelo mesmo motor; zero vantagem |
| 0012 | **Git Flow simplificado, uma fase por branch** | Rastreabilidade fase↔PR↔handoff; `main` sempre publicável |
| 0013 | **GUT + runner headless próprio + benchmarks próprios** | Testar o jogo, não só funções |
| 0014 | **Simulação 60 Hz fixa, render livre, interpolação manual** | Determinismo + fluidez em 120 Hz |

## 2. Decisões de produto tomadas no planejamento

| Decisão | Escolha | Motivo |
|---|---|---|
| Nome | **VOLTA** (título de trabalho) | Nomeia o verbo do jogo; leitura elétrica; pendência de marca em RISK-012 |
| Orientação | Portrait travado | Jogo de uma mão; simplifica UI e câmera |
| Modo do MVP | Só Classic | Provar o loop antes de multiplicar variações |
| Monetização | Só cosmético + remove ads | Pilar 5 (Justiça) |
| Anúncios | Só rewarded opt-in, a partir da GSD 25 | Não estragar a primeira impressão |
| Multiplayer no v0.1.0 | **Não** | Arquitetura sim (GSD 17), recurso lançável não |
| Idiomas | en + pt-BR | Mercado inicial e custo de manutenção |
| Progressão | Sem impacto em gameplay | Pilar 5 |
| Onboarding | Dentro da primeira partida | Não existe tela de tutorial |
| Arenas no v0.1.0 | 5 | Variedade suficiente sem inflar QA |
| Save de partida em andamento | Não | Partida de 3 min; complexidade sem retorno |

## 3. Decisões deliberadamente adiadas

| Assunto | Quando decidir | Por quê |
|---|---|---|
| Upgrade de versão da engine | GSD 20 | Precisa de medição real em dispositivo |
| Chunks / otimização estrutural do grid | só se um benchmark estourar | Otimização sem medição é dívida |
| `SealSolver` em GDExtension (C++) | último recurso, se GSD 19 exigir | Custo de build multiplataforma |
| Final Push em Domination | até a Alpha | Precisa de playtest |
| Roubo dando Surge extra | até a Alpha | Precisa de dados de balanceamento |
| Arenas com obstáculo móvel | pós-launch | Escopo |
| Provedor de crash reporting | GSD 18 | Depende do backend estar de pé |
| Season pass | pós-launch | Depende de retenção real |

## 4. Decisões que exigem humano

| # | Assunto | Prazo | Por quê |
|---|---|---|---|
| H-01 | Registro/aprovação do nome e busca de marca | antes da GSD 21 | Jurídico |
| H-02 | Contas de loja (Play US$ 25, Apple US$ 99/ano) | GSD 21/22 | Custo e identidade |
| H-03 | Hospedagem da API e domínio | GSD 15 | Custo |
| H-04 | Licença de fonte comercial | GSD 08 | Custo e jurídico |
| H-05 | Preços finais de IAP por região | GSD 25 | Produto |
| H-06 | Política de privacidade publicada | GSD 21 | Jurídico |
| H-07 | Provedor de anúncios (se e quando) | GSD 25 | Produto e receita |

Nenhuma delas bloqueia as fases 01 a 14.
