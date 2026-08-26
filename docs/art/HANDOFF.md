# Art Handoff & Equity Audit

## Competitive Equity Rules

To prevent Pay-To-Win scenarios, all cosmetic assets must adhere strictly to these isolation rules:

### 1. Runner Skins
- **Hitboxes**: Cosmetic skins do not touch `CollisionResolver` logic. The logical radius of a Runner is strictly 10.0 units on the grid regardless of the skin.
- **Markers**: All skins must prominently display the player's geometric shape (Circle, Diamond, Triangle, etc.) to ensure readability in 4+ player matches.

### 2. Arc Styles
- **Width**: Custom arc shaders cannot increase or decrease the visual width of the trail beyond a 10% threshold of the base `Arc` style, ensuring opponents can always accurately judge distances.
- **Warning Colors**: High-overload warning colors (Amber flashing) must override any custom shader colors.

### 3. VFX / Seal Effects
- **Duration**: All Seal effects last precisely 0.4 seconds total (0.12s sweep + 0.28s fill). Shaders must terminate at this point.
- **Obfuscation**: No explosion or flash can exceed a set alpha threshold (0.8 max) in its center, ensuring runners underneath it remain partially visible.

## Conclusion
The Cosmetic Item schema is strictly decoupled from `RunnerState` and `TerritoryGrid`. Cosmetics only instruct the presentation layer on which materials and textures to load. Gameplay determinism is fully preserved.
