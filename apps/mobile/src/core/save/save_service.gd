class_name SaveService
extends RefCounted

## Interface abstrata do serviço de save (docs/architecture/save-system.md §6). Consumidores
## nunca escrevem no disco direto — só conhecem esta interface. `FileSaveService` é a
## implementação concreta (Task 2). Base "virtual": cada método falha alto se chamado
## diretamente, igual a LogSink/SaveMigration.

enum SaveResult { OK, RESTORED_FROM_BACKUP, RECREATED }


func load_profile() -> SaveResult:
	push_error("SaveService.load_profile() não implementado")
	return SaveResult.RECREATED


func save_profile(now: bool = false) -> void:
	push_error("SaveService.save_profile() não implementado")


func load_settings() -> SaveResult:
	push_error("SaveService.load_settings() não implementado")
	return SaveResult.RECREATED


func save_settings() -> void:
	push_error("SaveService.save_settings() não implementado")


func mark_dirty(section: StringName) -> void:
	push_error("SaveService.mark_dirty() não implementado")


func export_blob() -> PackedByteArray:
	return PackedByteArray()


func import_blob(_blob: PackedByteArray) -> int:
	return SaveResult.RECREATED
