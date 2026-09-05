extends GutTest

## StatBlock (docs/design/balance.md §2). Garante que base_speed/base_turn_rate vêm de
## RunnerBalance — nunca de um literal duplicado em stat_block.gd — e que os modificadores
## empilham e removem sem resíduo (MOVE-003, TESTS.md test_stat_block.gd).

func test_defaults_come_from_runner_balance() -> void:
	var stats := StatBlock.new()
	assert_eq(stats.get_speed(), 220.0)
	assert_eq(stats.get_turn_rate(), 540.0)

func test_custom_balance_overrides_defaults() -> void:
	var balance := RunnerBalance.new()
	balance.base_speed = 300.0
	balance.turn_rate = 720.0
	var stats := StatBlock.new(balance)
	assert_eq(stats.get_speed(), 300.0)
	assert_eq(stats.get_turn_rate(), 720.0)

func test_speed_modifiers_stack_and_remove_without_residue() -> void:
	var stats := StatBlock.new()
	var base := stats.get_speed()
	stats.add_speed_modifier(50.0)
	stats.add_speed_modifier(-20.0)
	assert_eq(stats.get_speed(), base + 30.0)
	stats.remove_speed_modifier(50.0)
	stats.remove_speed_modifier(-20.0)
	assert_eq(stats.get_speed(), base, "remover todos os modificadores deveria voltar ao valor base")

func test_turn_rate_modifiers_stack_and_remove_without_residue() -> void:
	var stats := StatBlock.new()
	var base := stats.get_turn_rate()
	stats.add_turn_rate_modifier(100.0)
	assert_eq(stats.get_turn_rate(), base + 100.0)
	stats.remove_turn_rate_modifier(100.0)
	assert_eq(stats.get_turn_rate(), base)

func test_speed_never_goes_negative() -> void:
	var stats := StatBlock.new()
	stats.add_speed_modifier(-99999.0)
	assert_eq(stats.get_speed(), 0.0)
