---
wave: 3
depends_on: [02-solver-PLAN]
files_modified:
  - src/presentation/territory_renderer.gd
  - assets/shaders/territory.gdshader
  - src/presentation/arc_renderer.gd
  - assets/shaders/arc.gdshader
  - src/presentation/seal_animation.gd
  - src/presentation/camera/game_camera.gd
  - src/territory/grid_serializer.gd
  - tools/dev/simulate.gd
autonomous: true
requirements:
  - TER-06
  - TER-07
---

# 03-render-PLAN.md

## Objective
Implement constant-cost Territory rendering via ImageTexture and shaders, render Arcs, add Seal animations, dynamic camera zoom, and simulation invariants tool.

## Tasks

<task>
  <objective>TERR-009: Territory Rendering</objective>
  <read_first>
    - .gsd/phases/03-territory-engine/TASKS.md
  </read_first>
  <action>
    Create `src/presentation/territory_renderer.gd` updating an `ImageTexture` directly.
    Create `assets/shaders/territory.gdshader` using the texture as a lookup for colors/borders.
    Ensure rendering is 1 draw call via a single quad/sprite.
  </action>
  <acceptance_criteria>
    - `src/presentation/territory_renderer.gd` updates an Image object and uses a ShaderMaterial.
    - `assets/shaders/territory.gdshader` exists and reads the texture.
  </acceptance_criteria>
</task>

<task>
  <objective>TERR-010: Arc Rendering</objective>
  <read_first>
    - .gsd/phases/03-territory-engine/TASKS.md
  </read_first>
  <action>
    Create `src/presentation/arc_renderer.gd` utilizing `Line2D` or `MultiMeshInstance2D`.
    Create `assets/shaders/arc.gdshader` to handle glow based on length.
  </action>
  <acceptance_criteria>
    - `src/presentation/arc_renderer.gd` draws the arc paths.
  </acceptance_criteria>
</task>

<task>
  <objective>TERR-011: Seal Animation</objective>
  <read_first>
    - .gsd/phases/03-territory-engine/TASKS.md
  </read_first>
  <action>
    Create `src/presentation/seal_animation.gd` to instantiate and manage a radial mask effect (via tweening a shader parameter on a sprite) starting from the capture point.
  </action>
  <acceptance_criteria>
    - `src/presentation/seal_animation.gd` plays a visual effect without blocking simulation.
  </acceptance_criteria>
</task>

<task>
  <objective>TERR-012: Dynamic Camera Zoom</objective>
  <read_first>
    - .gsd/phases/03-territory-engine/TASKS.md
  </read_first>
  <action>
    Update `src/presentation/camera/game_camera.gd` to smoothly adjust `zoom` property based on the runner's `claim_percent`.
  </action>
  <acceptance_criteria>
    - `src/presentation/camera/game_camera.gd` modifies zoom according to territory size.
  </acceptance_criteria>
</task>

<task>
  <objective>TERR-013 & TERR-014: Tools & Invariants</objective>
  <read_first>
    - .gsd/phases/03-territory-engine/TASKS.md
  </read_first>
  <action>
    Create `src/territory/grid_serializer.gd` to convert the grid state to bytes.
    Create `tools/dev/simulate.gd` to run headless matches with random walks and assert `TerritoryGrid` invariants every tick.
  </action>
  <acceptance_criteria>
    - `src/territory/grid_serializer.gd` handles binary serialization.
    - `tools/dev/simulate.gd` can run multiple headless steps.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: Territory renders in 1 draw call via shader. Arcs are visible. Camera zooms out as territory grows. Headless simulation tool exists.
