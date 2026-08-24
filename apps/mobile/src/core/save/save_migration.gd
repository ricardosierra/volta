class_name SaveMigration
extends RefCounted

## Base de migração encadeada (docs/architecture/save-system.md §4). Cada subclasse concreta
## migra de `from_version()` para `to_version()`; `FileSaveService` encadeia várias instâncias
## registradas até não haver mais migração cujo `from_version()` bata com o schema_version atual
## do save carregado — nunca "pula" versão.

func from_version() -> int:
	push_error("SaveMigration.from_version() não implementado em %s" % [get_script()])
	return -1


func to_version() -> int:
	push_error("SaveMigration.to_version() não implementado em %s" % [get_script()])
	return -1


func migrate(data: Dictionary) -> Dictionary:
	push_error("SaveMigration.migrate() não implementado em %s" % [get_script()])
	return data
