# Geração de Assets com IA — Guias e Prompts

Este documento contém os prompts exatos e diretrizes para gerar os assets visuais do jogo mantendo **coerência estética absoluta**.

**Ferramentas Exigidas:**
- **Imagens / Sprites / Texturas:** NanoBanana (via conta `sierra.csi@gmail.com`)
- **Vídeos / Animações de Efeitos:** Google Flow (via navegador web na conta `sierra.csi@gmail.com`)

---

## 1. Regras Base de Estilo (Global)
*Sempre inclua este sufixo no final dos prompts de imagem do NanoBanana para garantir coerência:*
> `Style: Vector art, flat colors, clean neon glow, sci-fi minimalist, dark background, esports identity, sharp edges, no gradients inside vectors, 2D top-down perspective.`

---

## 2. Prompts NanoBanana (Imagens Estáticas e Sprites)

### A. Botões e UI Base (VButton, VCard)
**Prompt:**
> `A UI button asset for a sci-fi mobile game. Neon cyan border, dark charcoal filling, slightly rounded corners, glowing edges, isolated on pure black background, flat design, clean geometry. Style: Vector art, flat colors, clean neon glow, sci-fi minimalist, dark background, esports identity, sharp edges, no gradients inside vectors, 2D top-down perspective.`

### B. O *Runner* (Avatar do Jogador)
**Prompt:**
> `A minimalist top-down 2D sci-fi vehicle or futuristic cursor, sleek aerodynamic triangle shape, glowing neon accents, isolated on pure black background. Style: Vector art, flat colors, clean neon glow, sci-fi minimalist, dark background, esports identity, sharp edges, no gradients inside vectors, 2D top-down perspective.`

### C. Ícones do Main Menu (Play, Settings, Moedas)
**Prompt:**
> `A minimalist flat 2D icon of a [gears / play symbol / digital coin]. Glowing neon outline, transparent center, high contrast, clean SVG look, isolated on pure black background. Style: Vector art, flat colors, clean neon glow, sci-fi minimalist, dark background, esports identity, sharp edges, no gradients inside vectors, 2D top-down perspective.`

---

## 3. Prompts Google Flow (Animações e Vídeos)

As animações devem ser renderizadas no Google Flow (através do navegador) exportando frames PNG ou Spritesheets para usar na Godot.

### A. Efeito de *Seal* (Conquista de Território)
**Prompt Google Flow:**
> `A top-down view of a neon grid line instantly illuminating and filling the enclosed space with a digital holographic pulse. Rapid expansion, sci-fi energy ripple effect, clean geometry, 60fps, high contrast neon cyan against pitch black, flat graphic style, no realistic lighting, purely vector motion graphics.`

### B. Efeito de *Break / Hit* (Morte do Runner)
**Prompt Google Flow:**
> `A minimalist geometric shape shattering into digital shards. Sci-fi neon glitch effect, fast energetic burst, pixelated debris dissolving into a black background, 60fps, motion graphics style, flat colors, high contrast.`

### C. Efeito de *Backwash* (Penalidade)
**Prompt Google Flow:**
> `A digital UI warning pulse, neon red glitching waves expanding outward from the center, brief electric discharge effect, 60fps, purely 2D motion graphics, minimal vector style on black background.`

---

## Procedimento Operacional
1. Faça login em ambas as ferramentas usando `sierra.csi@gmail.com`.
2. Copie e cole os prompts literais deste documento.
3. Não use prompts genéricos ou de "fantasia/realismo". O jogo é **abstrato e competitivo (eSports vibe)**.
4. Salve todas as saídas brutas em `.png` com transparência e coloque na pasta `assets/raw/`.
