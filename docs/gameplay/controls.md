# Controles

> Meta dura: **latência toque → mudança de direção < 50 ms**, medida em dispositivo real
> (GSD 02, verificada de novo em GSD 19). Controle ruim mata o jogo antes de qualquer bug.

Todo esquema de controle implementa a mesma interface e produz o mesmo dado: um **vetor de
direção desejada**. A simulação não sabe qual esquema está ativo.

```gdscript
class_name InputDriver
func poll(delta: float) -> Vector2   # direção desejada normalizada, ou Vector2.ZERO
func is_active() -> bool
```

---

## Esquema 1 — Swipe direcional (padrão)

Arraste em qualquer lugar da tela. A direção do arraste vira a direção desejada.

- Reconhece a partir de um deslocamento mínimo (dead zone em **mm físicos**, não em pixels —
  a mesma distância física em qualquer densidade de tela).
- Enquanto o dedo estiver na tela, a direção continua sendo atualizada.
- Ao soltar, o Runner **mantém** a última direção. Nunca para sozinho.
- Buffer de input: se dois swipes chegam mais rápido que a taxa de giro, o segundo fica
  na fila e é aplicado assim que o primeiro for atingido. Nenhum toque é descartado.

Padrão para novos jogadores. É o que o onboarding ensina.

---

## Esquema 2 — Joystick virtual

Aparece onde o dedo tocar (*floating*), some ao soltar.

- Posição e tamanho configuráveis; opção de fixá-lo num canto.
- Zona morta e raio máximo configuráveis (ver `Settings > Controls`).
- Opção "manter direção ao soltar" (padrão ligado, coerente com o esquema 1).

Preferido por jogadores vindos de outros `.io` e por quem joga com o polegar apoiado.

---

## Esquema 3 — Relativo (steering)

O arraste indica **quanto girar**, não para onde ir: arrastar para a direita gira no sentido
horário, proporcional à distância.

- Sensibilidade configurável.
- Permite curvas longas e precisas com movimento mínimo do dedo.
- Nicho, mas é o esquema que jogadores avançados costumam adotar para arcos apertados.

---

## Configurações (`Settings > Controls`)

| Opção | Padrão | Observação |
|---|---|---|
| Esquema | Swipe | Swipe · Joystick · Relativo |
| Sensibilidade | 1,0 | 0,5 – 2,0 |
| Zona morta | média | pequena · média · grande (em mm) |
| Manter direção ao soltar | ligado | |
| Mão dominante | destra | espelha HUD e joystick |
| Zona de toque | tela inteira | ou metade inferior, para não cobrir o campo |
| Vibração de input | desligado | háptico mínimo a cada troca de direção |
| **Test drive** | — | mini-arena embutida na tela de settings, muda ao vivo |

O *test drive* é obrigatório: trocar de esquema sem poder experimentar na hora é hostil.

---

## Regras de implementação

1. `InputRouter` escolhe o driver ativo; o resto do jogo depende só da interface.
2. Todo input é amostrado no **tick de simulação** (60 Hz fixo), nunca no `_process` de render —
   ver [`ADR-0014`](../decisions/ADR-0014-simulation-tick-model.md).
3. Nenhum toque é consumido por UI durante a partida, exceto a área explícita do botão de pause
   (com margem de segurança e safe area respeitada).
4. Multi-toque: o primeiro dedo controla; os demais são ignorados (sem trocar o controle no meio).
5. Toque que começa sobre um elemento de UI não vira input de movimento.
6. Suporte a teclado/gamepad existe **apenas** para desenvolvimento e testes automatizados —
   nunca aparece no menu do jogador.
