class_name RunnerViewSpawner
extends Node

## Cria a RunnerView correspondente sempre que MatchDirector (camada de simulação) sinaliza
## que um novo Runner passou a existir. Mantém gameplay/ sem conhecer a camada de
## apresentação (docs/architecture/overview.md §1, CLAUDE.md §5) — a inversão de dependência
## mora aqui: quem ESCUTA é apresentação, quem EMITE é simulação.

func watch(director: MatchDirector) -> void:
	director.runner_spawned.connect(_on_runner_spawned)


func _on_runner_spawned(runner: Runner) -> void:
	var view := RunnerView.new()
	add_child(view)
	view.runner = runner
	view.global_position = runner.state.position

	# If catalog/loadout are available via Autoload, we would apply cosmetics here
