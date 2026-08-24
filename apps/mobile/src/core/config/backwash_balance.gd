class_name BackwashBalance
extends Resource

## Contrato tipado dos parâmetros de Backwash (docs/design/balance.md §3). Os defaults abaixo
## SÃO os valores 🎯 do documento — não arredondados. Campos bool não têm faixa de validação
## (ConfigValidator os ignora — ver <behavior> do plano).

@export_range(-0.9, 0.0) var speed_penalty: float = -0.40
@export_range(0.0, 10.0) var penalty_duration: float = 1.2
@export var reset_surge_on_backwash: bool = true
@export var tangent_deflection: bool = true
