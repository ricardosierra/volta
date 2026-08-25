---
wave: 1
depends_on: []
files_modified:
  - docs/art/asset_generation_prompts.md
  - src/ui/design_system/tokens/theme_palette.gd
  - resources/themes/neon.tres
  - src/ui/components/safe_area_container.gd
autonomous: true
requirements:
  - UIX-01
  - UIX-02
---

# 01-tokens-safearea-PLAN.md

## Objective
Establish the Design System Tokens, Safe Area responsiveness, and write the Asset Generation Guidelines for external tools.

## Tasks

<task>
  <objective>Asset Prompts Documentation</objective>
  <read_first>
    - .gsd/phases/07-ui-ux-foundation/TASKS.md
  </read_first>
  <action>
    Create `docs/art/asset_generation_prompts.md` detailing exact prompts and style guides to be used in "NanoBanana" and "Google Flow" under the `sierra.csi@gmail.com` account. Ensures aesthetic consistency.
  </action>
  <acceptance_criteria>
    - Document exists with clear copy-paste prompts for buttons, backgrounds, character previews, and animations.
  </acceptance_criteria>
</task>

<task>
  <objective>UIUX-001: Design System Tokens</objective>
  <read_first>
    - .gsd/phases/07-ui-ux-foundation/TASKS.md
  </read_first>
  <action>
    Create `src/ui/design_system/tokens/theme_palette.gd`.
    Create a base `resources/themes/neon.tres` mapping theme properties.
  </action>
  <acceptance_criteria>
    - Tokens are centralized.
  </acceptance_criteria>
</task>

<task>
  <objective>UIUX-002: SafeAreaContainer</objective>
  <read_first>
    - .gsd/phases/07-ui-ux-foundation/TASKS.md
  </read_first>
  <action>
    Create `src/ui/components/safe_area_container.gd` that reads device safe areas and adjusts its margins dynamically.
  </action>
  <acceptance_criteria>
    - Container correctly pads content away from notches and corners.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: Token system works. Prompts document is complete and instructs the user how to generate cohesive assets using NanoBanana/Google Flow.
