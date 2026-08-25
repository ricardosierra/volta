---
wave: 2
depends_on: [01-tokens-safearea-PLAN]
files_modified:
  - src/ui/components/v_button.gd
  - src/ui/components/v_card.gd
  - src/ui/design_system/showcase.tscn
  - src/ui/navigation/screen_stack.gd
  - src/ui/navigation/screen.gd
autonomous: true
requirements:
  - UIX-03
  - UIX-04
  - UIX-05
---

# 02-components-nav-PLAN.md

## Objective
Build base UI components, the Showcase scene, and the Navigation Screen Stack.

## Tasks

<task>
  <objective>UIUX-003 & UIUX-004: Base Components & Showcase</objective>
  <read_first>
    - .gsd/phases/07-ui-ux-foundation/TASKS.md
  </read_first>
  <action>
    Create `src/ui/components/v_button.gd` and `v_card.gd`.
    Create `src/ui/design_system/showcase.tscn` displaying these components in all states.
  </action>
  <acceptance_criteria>
    - Base components inherit from tokens.
    - Showcase scene runs without errors.
  </acceptance_criteria>
</task>

<task>
  <objective>UIUX-005: Navigation</objective>
  <read_first>
    - .gsd/phases/07-ui-ux-foundation/TASKS.md
  </read_first>
  <action>
    Create `src/ui/navigation/screen_stack.gd` to handle push/pop of screens with transitions.
    Create base `src/ui/navigation/screen.gd`.
  </action>
  <acceptance_criteria>
    - Navigation stack handles Android back button and prevents unbounded depth.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: Navigation stack controls UI flow. Buttons are tokenized. Showcase works.
