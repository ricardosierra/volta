# Acessibilidade

> Não é um item de checklist do fim do projeto. É requisito de design desde o primeiro pixel —
> e várias das opções aqui deixam o jogo melhor para **todo mundo**.

## Visão

| Recurso | Implementação | Fase |
|---|---|---|
| **Cor + forma** | cada Runner tem uma cor **e** um marcador geométrico (círculo, losango, triângulo, hexágono, estrela…) no centro e no padrão de preenchimento do Claim | 08 |
| **Paletas para daltonismo** | temas dedicados: Deuteranopia, Protanopia, Tritanopia, com contraste verificado par a par | 20 |
| **Contraste mínimo** | 4,5:1 para texto, 3:1 para elementos de UI; verificado por script no CI de design | 08 |
| **Escala de UI** | 0,9 – 1,25 | 07 |
| **Reduzir flashes** | remove flashes de tela cheia, suaviza glow pulsante, limita partículas brilhantes | 09 |
| **Reduzir shake** | escala global de screen shake, incluindo 0 | 09 |
| **Alto contraste** | modo que aumenta a separação entre Claim, Arc e fundo, reduzindo o atmosférico | 20 |

## Motora

| Recurso | Fase |
|---|---|
| Três esquemas de controle + sensibilidade + zona morta | 02/07 |
| Modo canhoto (espelha HUD e joystick) | 07 |
| Alvos de toque ≥ 48 dp em toda a UI | 07 |
| "Manter direção ao soltar" (não exige segurar o dedo) | 02 |
| Pause acessível com uma mão | 07 |
| Nenhuma ação exige toque duplo, longo ou multitoque | sempre |

## Auditiva

| Recurso | Fase |
|---|---|
| Nenhuma informação existe **só** no áudio | sempre |
| Volumes independentes (Master, Music, SFX) | 07 |
| Feedback háptico como canal alternativo ao som | 09 |

## Cognitiva

| Recurso | Fase |
|---|---|
| Tutorial dentro do jogo, um passo por vez, sem tempo limite | 07 |
| Sem texto essencial que suma antes de 2 s | 07 |
| Linguagem simples; nenhuma mecânica explicada só por ícone | 07 |
| Modo `HUD mínima` para reduzir carga visual | 07 |
| Sem penalidade por pausar | sempre |

## Teste

- Checklist executado no gate de **GSD 20** e de novo antes do release.
- Teste obrigatório: jogar uma partida inteira com `Reduce flashes` + `Reduce shake` +
  `Haptics off` + `UI scale 1,25` + tema de daltonismo — precisa continuar legível e divertido.
- Simulador de daltonismo aplicado em capturas de todas as telas e de 3 momentos de partida.
- Verificação de contraste automatizada sobre os tokens de cada tema.
