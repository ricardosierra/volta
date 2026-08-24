extends GutTest

## ConfigService + ConfigValidator (docs/architecture/configuration.md §2,
## .gsd/phases/01-repository-foundation/TESTS.md). Cobre: config válida, valor fora de faixa,
## campo ausente, todos os 6 balances carregando sem erro, e coerência entre arquivos.


func test_valid_config_loads() -> void:
	var svc := ConfigService.new()
	assert_true(svc.load_all())
	assert_eq(svc.runner().base_speed, 220.0)


func test_out_of_range_value_detected() -> void:
	var resource := RunnerBalance.new()
	resource.base_speed = 99999.0
	var invalid := ConfigValidator.validate(resource)
	assert_true(invalid.has("base_speed"))


func test_missing_field_detected() -> void:
	# "Campo ausente" é modelado zerando um campo cujo range mínimo é > 0 (arc_max_cells:
	# 100-5000) — representa um campo que deveria ter sido preenchido mas ficou no valor
	# inválido de tipo (0). É detectado pelo mesmo mecanismo de faixa de validate(), sem
	# precisar de um segundo código de validação (ver <behavior> do plano 01-04).
	var resource := RunnerBalance.new()
	resource.arc_max_cells = 0
	var invalid := ConfigValidator.validate(resource)
	assert_true(invalid.has("arc_max_cells"))


func test_all_six_balances_load_without_error() -> void:
	var svc := ConfigService.new()
	assert_true(svc.load_all())
	assert_eq(svc.get_load_error(), "")


func test_cross_file_coherence_detected() -> void:
	# Cada valor individualmente está dentro da própria faixa — só a regra entre arquivos pega
	# que um Arc de 4999 células não cabe num grid pequeno de 32x32 = 1024 células.
	var runner := RunnerBalance.new()
	runner.arc_max_cells = 4999
	var territory := TerritoryBalance.new()
	territory.grid_small_width = 32
	territory.grid_small_height = 32
	var camera := CameraBalance.new()
	var incoherent := ConfigValidator.validate_coherence(runner, territory, camera)
	assert_true(incoherent.has("arc_max_cells"))


func test_embedded_defaults_are_coherent() -> void:
	# Garante que o fallback _reset_to_embedded() do ConfigService nunca é, ele mesmo,
	# incoerente entre arquivos.
	var incoherent := ConfigValidator.validate_coherence(RunnerBalance.new(), TerritoryBalance.new(), CameraBalance.new())
	assert_true(incoherent.is_empty())
