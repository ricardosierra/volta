class_name LogCategory
extends RefCounted

## Categorias de log estruturado. Cada uma liga/desliga de forma independente, em runtime,
## pelo menu de debug. Ver docs/architecture/logging.md.

enum Category {
	GAMEPLAY,
	TERRITORY,
	AI,
	INPUT,
	UI,
	SAVE,
	NETWORK,
	AUDIO,
	PERFORMANCE,
	ERROR,
}
