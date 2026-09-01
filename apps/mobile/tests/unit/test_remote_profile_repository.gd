extends GutTest

## Cobre o bug encontrado na auditoria da Fase 26: load_profile() chamava um método
## inexistente em LocalProfileRepository (get_profile é o nome real).

func test_load_profile_delegates_to_local_cache() -> void:
	var cache := LocalProfileRepository.new()
	var repo := RemoteProfileRepository.new(null, null, cache)

	var profile: Profile = repo.load_profile()

	assert_not_null(profile, "load_profile() deve devolver o Profile vindo do cache local")
