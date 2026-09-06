class_name RemoteChallengeRepository
extends RefCounted

## MOCK
##
## Replacement Phase: GSD 16
## Replacement Task: ONLI-004
##
## Este arquivo nunca compilou: nasceu na Fase 25 estendendo `ChallengeRepository`, uma classe
## que não existe no projeto (GSD 02, Plano 02-07). Passou despercebido porque nenhuma cena o
## alcança, e `check-project.sh` só compila o que sai de `root.gd`.
##
## `get_daily_challenges()` dispara a chamada e devolve lista vazia sem esperar resposta — o
## `ApiClient` é assíncrono e ninguém consome o resultado ainda. A implementação real (com
## await fora do caminho de simulação, cache local e fallback offline) é da Fase 16, junto com
## a troca de `Local*` por `Remote*`. Até lá isto é um mock declarado, não um serviço.

var api: ApiClient

func _init(api_client: ApiClient) -> void:
	api = api_client

func get_daily_challenges() -> Array:
	if api:
		api.get_data("/challenges/daily")
	return []
