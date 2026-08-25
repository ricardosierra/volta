---
wave: 1
depends_on: []
files_modified:
  - src/core/fsm/state_machine.gd
  - src/core/fsm/state.gd
  - src/gameplay/game_state.gd
  - src/gameplay/states/boot_state.gd
  - src/gameplay/states/menu_state.gd
  - src/gameplay/states/loading_state.gd
  - src/gameplay/states/countdown_state.gd
  - src/gameplay/states/playing_state.gd
  - src/gameplay/states/paused_state.gd
  - src/gameplay/states/results_state.gd
  - src/gameplay/match_director.gd
  - src/gameplay/simulation_clock.gd
autonomous: true
requirements:
  - MOV-01
  - MOV-02
---

# 01-sim-loop-PLAN.md

## Objective
Implement generic type-safe State Machine, the Game FSM, and the deterministic 60Hz physics tick simulation loop.

## Tasks

<task>
  <objective>MOVE-001: Implement generic FSM and Game FSM</objective>
  <read_first>
    - .gsd/phases/02-core-movement/TASKS.md
    - docs/architecture/state-machines.md
  </read_first>
  <action>
    Create `src/core/fsm/state.gd` (class_name State) with enter, exit, and update methods.
    Create `src/core/fsm/state_machine.gd` (class_name StateMachine) with add_state, add_transition, request, tick, and signal state_changed.
    Implement invalid transition handling: use `assert(false)` in debug, and log `push_error` while ignoring the transition in release.
    Create `src/gameplay/game_state.gd` (extends Node) which sets up the state machine for the game.
    Create state classes for Boot, Menu, Loading, Countdown, Playing, Paused, and Results.
    Implement Paused state to freeze `_physics_process` in the tree.
  </action>
  <acceptance_criteria>
    - `src/core/fsm/state_machine.gd` exists and has `add_state`, `add_transition`, `request`, `tick`.
    - `src/gameplay/states/paused_state.gd` exists and modifies `get_tree().paused` or equivalent.
  </acceptance_criteria>
</task>

<task>
  <objective>MOVE-002: Implement deterministic simulation loop</objective>
  <read_first>
    - .gsd/phases/02-core-movement/TASKS.md
    - docs/decisions/ADR-0014-simulation-tick-model.md
  </read_first>
  <action>
    Create `src/gameplay/simulation_clock.gd` (class_name SimulationClock) to track ticks and game seed.
    Create `src/gameplay/match_director.gd` (class_name MatchDirector) to run the simulation loop inside `_physics_process`.
    Implement the fixed order: input -> (AI) -> movement -> (territory) -> (rules) -> events.
    Provide a `step(dt)` API on MatchDirector for headless testing.
    Ensure `Engine.max_fps` is synced with the panel rate but physics is fixed to 60.
  </action>
  <acceptance_criteria>
    - `src/gameplay/match_director.gd` contains `func _physics_process(delta: float):`
    - `src/gameplay/simulation_clock.gd` tracks a `current_tick` variable.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: FSM has valid transitions and asserts on invalid ones. MatchDirector runs physics steps in deterministic order.
