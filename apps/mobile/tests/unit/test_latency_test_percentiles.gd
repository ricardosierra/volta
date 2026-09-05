extends GutTest

## LatencyTest.percentile() — matemática pura e testável (MOVE-010). O resto da
## instrumentação (evento -> tick -> frame) só produz número real em dispositivo, mas o
## cálculo de percentil não pode ser fabricado (CLAUDE.md, Regra de Ouro Anti-Burla) — por
## isso é uma função estática, independente de estado de partida, testável com amostras
## sintéticas.

func test_percentile_of_empty_array_is_negative_one() -> void:
	assert_eq(LatencyTest.percentile([], 0.5), -1.0)

func test_p50_of_ten_sorted_samples() -> void:
	var samples: Array = [10.0, 20.0, 30.0, 40.0, 50.0, 60.0, 70.0, 80.0, 90.0, 100.0]
	assert_eq(LatencyTest.percentile(samples, 0.5), 50.0)

func test_p95_of_ten_sorted_samples() -> void:
	var samples: Array = [10.0, 20.0, 30.0, 40.0, 50.0, 60.0, 70.0, 80.0, 90.0, 100.0]
	assert_eq(LatencyTest.percentile(samples, 0.95), 100.0)

func test_percentile_does_not_depend_on_input_order() -> void:
	var sorted_samples: Array = [1.0, 2.0, 3.0, 4.0, 5.0]
	var shuffled_samples: Array = [5.0, 1.0, 4.0, 2.0, 3.0]
	assert_eq(LatencyTest.percentile(sorted_samples, 0.5), LatencyTest.percentile(shuffled_samples, 0.5))

func test_single_sample_returns_that_sample_for_any_percentile() -> void:
	assert_eq(LatencyTest.percentile([42.0], 0.5), 42.0)
	assert_eq(LatencyTest.percentile([42.0], 0.95), 42.0)
