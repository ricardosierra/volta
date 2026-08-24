# Configuração orientada a dados

> Nenhum número de gameplay dentro de um `.gd`. Se alguém precisa mudar o comportamento do
> jogo, muda um `.tres` — sem recompilar a cabeça de ninguém.

## 1. Onde as coisas moram

```text
packages/shared/config/          fonte de verdade, versionada, revisada em PR
├── balance/
│   ├── runner.tres              velocidade, giro, raio, invulnerabilidade
│   ├── territory.tres           tamanho de célula, grids, limites do Arc
│   ├── backwash.tres            penalidades
│   ├── score.tres               constantes da fórmula
│   ├── surge.tres               janelas, passos, teto
│   └── camera.tres              zoom, smoothing, punches
├── modes/                       classic.tres, time_attack.tres, survival.tres, ...
├── arenas/                      open_field.tres, archipelago.tres, ...
├── bots/                        rookie.tres, skilled.tres, elite.tres + arquétipos
├── powerups/                    bulwark.tres, overdrive.tres, ...
├── progression/                 curva de XP, recompensas de rank, pool de desafios
├── economy/                     preços, torneiras, tetos
└── quality/                     presets low/medium/high
```

Os `.tres` são **importados** para `apps/mobile/resources/` no build (link/cópia validada pelo
CI). A duplicação existe para que o projeto Godot continue autocontido, e a fonte única
continue sendo `packages/shared`.

## 2. Como se lê configuração

```gdscript
var balance := ConfigService.balance()      # tipado, carregado uma vez, cacheado
runner.speed = balance.runner.base_speed
```

- `ConfigService` carrega tudo no `Boot` e valida.
- **Validação obrigatória** na carga: faixa de valores, campos obrigatórios, coerência entre
  arquivos (ex.: `arc_max_cells` maior que o perímetro possível do grid). Config inválida
  **falha alto** em debug e cai no valor embutido em release, logando `ERROR`.
- Nada de `ConfigService.get("player.speed")` com string solta: acesso é por propriedade tipada.

## 3. Remote config (GSD 16)

```text
BakedRemoteConfig (padrão)  →  valores dos .tres embutidos
HttpRemoteConfig            →  busca overrides, valida, aplica, cacheia
```

Regras:
- Override só pode **ajustar valores existentes**, nunca introduzir chave nova nem mudar tipo.
- Todo override tem faixa mínima/máxima declarada no `.tres` — o servidor não pode mandar
  `base_speed = 99999`.
- Config remota nunca é aplicada no meio de uma partida.
- Falha de rede = valores embutidos. Sem exceção.

## 4. Perfis de qualidade

`quality/low|medium|high.tres` controlam: densidade de partículas, glow, sombras,
pós-processamento, qualidade do rastro, resolução de render, MSAA.

`Auto` decide no primeiro boot por: total de RAM, contagem de núcleos, renderer disponível e
um micro-benchmark de 1 s no boot; o resultado é salvo e pode ser sobrescrito pelo jogador.

## 5. Regras de review

- PR que adiciona literal numérico em arquivo de gameplay é rejeitado.
- PR que muda valor de balance precisa: número antigo → novo, motivo, e resultado do
  `simulate.sh` no corpo do PR.
- Toda chave nova de config entra em [`../design/balance.md`](../design/balance.md) no mesmo PR.
