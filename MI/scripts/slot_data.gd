extends Resource
class_name SlotData

const MAX_STACK: int = 99

@export var item_data: ItemData
@export_range(0, MAX_STACK) var cantidad: int = 0 : set = asignar_cantidad


func asignar_cantidad(valor: int)-> void:
	cantidad = valor
	if cantidad > 1 and not item_data.acumulable:
		cantidad = 1
		push_error("item no acumulable con cantidad mayor a 1")
