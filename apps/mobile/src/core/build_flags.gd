class_name BuildFlags
extends Resource

## Gerado/sobrescrito pelo pipeline de export para release (GSD 21 / ANDR-001).
## Em builds de debug e no editor, os valores abaixo (defaults do .tres commitado) valem.
@export var debug_tools_enabled: bool = true
@export var commit_sha: String = "dev"
