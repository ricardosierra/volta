# Orçamento de performance

> Alvo: **60 FPS estáveis no aparelho Mid** (ver `../mobile/device-matrix.md`), com suporte a
> 120 FPS onde o painel permitir. Orçamento é contrato: quem estoura, corta ou otimiza — não
> negocia depois.

## Frame budget

60 FPS = **16,6 ms**. Reservamos 20 % de folga para o sistema operacional e picos.
Orçamento real de trabalho: **13,3 ms**.

### CPU — 8,0 ms

| Sistema | Orçamento 🎯 | Observações |
|---|---|---|
| Simulação (tick 60 Hz) | 3,0 ms | ver quebra abaixo |
| Renderização (preparo, culling, batching) | 2,0 ms | |
| UI / HUD | 0,8 ms | HUD não redesenha o que não mudou |
| Áudio | 0,5 ms | |
| VFX (lógica de partículas na CPU) | 0,7 ms | |
| Engine / GC / diversos | 1,0 ms | |

### Simulação — 3,0 ms

| Subsistema | Orçamento 🎯 |
|---|---|
| Input | 0,05 ms |
| Movimento (8 Runners) | 0,20 ms |
| Território (Arc + colisões) | 0,10 ms |
| Seal (quando ocorre) | 0,80 ms típico · 4,0 ms pior caso |
| IA (2 bots por tick) | 1,20 ms |
| Regras / score / eventos | 0,30 ms |
| Câmera | 0,10 ms |

Pico de Seal + IA no mesmo tick é o pior caso conhecido: escalonamos as decisões de bot para
**nunca** coincidirem com um Seal previsto (o Seal é detectado no início do tick).

### GPU — 8,0 ms

| Item | Orçamento 🎯 |
|---|---|
| Field + Claims (1 quad + shader) | 1,0 ms |
| Arcs (MultiMesh) | 0,6 ms |
| Runners | 0,3 ms |
| VFX / partículas | 2,0 ms |
| Pós-processamento (glow) | 1,5 ms — **desligado no preset Low** |
| UI | 1,0 ms |
| Folga | 1,6 ms |

## Draw calls

| Preset | Alvo |
|---|---|
| Low | ≤ 40 |
| Medium | ≤ 80 |
| High | ≤ 120 |

O território inteiro é **1 draw call** (uma textura + shader), independentemente de quantas
células mudaram. É a razão de a representação ser um grid denso.

## Memória

| Item | Orçamento 🎯 |
|---|---|
| Grid (dois `PackedByteArray` 128×128) | 32 KB |
| Buffers do solver | 128 KB |
| Texturas | ≤ 24 MB |
| Áudio carregado | ≤ 12 MB |
| Cenas e scripts | ≤ 20 MB |
| **RSS total em partida** | **≤ 180 MB** no Mid |
| Crescimento após 10 partidas seguidas | **0 MB** (tolerância: ± 5 MB) |

## Tempo de carregamento

| Etapa | Alvo |
|---|---|
| Cold start até o menu | < 3,0 s |
| Menu → partida jogável | < 1,0 s |
| Results → nova partida | < 0,8 s |
| Troca de tema | < 0,2 s |

## Bateria e térmica

- < 8 %/hora de bateria em partida contínua no preset padrão do aparelho.
- Sem *thermal throttling* perceptível em 20 minutos contínuos no Mid.
- `low_processor_mode` disponível para quem quiser priorizar bateria.

## Tamanho do app

| Plataforma | Alvo |
|---|---|
| Android (AAB, download) | ≤ 60 MB |
| iOS (IPA) | ≤ 80 MB |

Arte vetorial e procedural existe justamente para caber nisso com folga.

## Como medimos

| Ferramenta | Uso |
|---|---|
| Godot Profiler | quebra por sistema no editor |
| Overlay de debug próprio | tempo por módulo em dispositivo real |
| `perf_sample` (analytics) | FPS p50/p10 por modelo em produção (GSD 18) |
| Android GPU Inspector / Xcode Instruments | GPU e memória em dispositivo |
| `tools/benchmarks/` | benchmarks reproduzíveis no CI |

## Regras

1. Orçamento estourado é **bug**, com a mesma prioridade de um crash de gameplay.
2. Regressão de performance acima de 10 % em relação ao baseline reprova o PR.
3. Toda feature nova declara seu custo estimado **antes** de ser implementada.
4. Otimização vem com medição antes/depois no PR. Sem número, não é otimização — é opinião.
