extends GutTest

## Testes de ServiceRegistry — register()/resolve() com a mesma instância, erro legível em
## resolve() de nome ausente (recuperável via get_last_error(), não só push_error), e
## proteção contra sobrescrita silenciosa em register() duplicado.

func test_register_then_resolve_returns_same_instance() -> void:
	var registry := ServiceRegistry.new()
	var instance := RefCounted.new()

	registry.register("x", instance)

	assert_eq(registry.resolve("x"), instance)


func test_resolve_missing_returns_null_with_readable_error() -> void:
	var registry := ServiceRegistry.new()

	var result := registry.resolve("missing")

	assert_null(result)
	assert_eq(registry.get_last_error(), "service_not_found:missing")
	# O push_error faz parte do contrato: quem chama resolve() errado tem de ver
	# o motivo no console, nao so um null. Declarar aqui tambem impede que o GUT
	# 9.7+ reprove o teste pelo erro que ele mesmo provoca de proposito.
	assert_push_error("não encontrado", "resolve() de serviço ausente avisa no console")


func test_register_duplicate_keeps_original() -> void:
	var registry := ServiceRegistry.new()
	var first := RefCounted.new()
	var second := RefCounted.new()

	registry.register("x", first)
	var second_registered := registry.register("x", second)

	assert_false(second_registered, "segundo register() do mesmo nome deveria falhar")
	assert_eq(registry.resolve("x"), first, "resolve() deveria continuar retornando a instância original")
	assert_eq(registry.get_last_error(), "service_already_registered:x")
	assert_push_error("já registrado", "registro duplicado avisa no console")
