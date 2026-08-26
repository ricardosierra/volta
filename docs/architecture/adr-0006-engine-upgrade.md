# ADR 0006: Godot Engine Version Strategy

## Context
Volta is currently on Godot 4.2. Godot 4.3 brings 2D physics interpolation natively, which we previously implemented manually.

## Decision
**Stay on 4.2 for Launch**. Our custom interpolation works perfectly with our deterministic tick system. Upgrading risks introducing regressions in the mobile renderer right before launch.

## Status
Accepted.
