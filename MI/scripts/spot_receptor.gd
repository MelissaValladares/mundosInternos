extends StaticBody3D

class_name SpotReceptor
@export var item_data : ItemData
signal data_emitted(data: ItemData)
var lleno : bool = false : set = cambiar_status_lleno
var seleccionado : bool = false : set = cambiar_status_seleccionado
var misma_mano : bool = false : set = cambiar_status_misma_mano

@onready var particulas = $particulas


func _process(delta):
	if seleccionado and misma_mano and not lleno:
		particulas.visible = true
	else:
		particulas.visible = false

func cambiar_status_lleno(status : bool):
	lleno = status

func cambiar_status_seleccionado(status : bool):
	seleccionado = status

func cambiar_status_misma_mano(status : bool):
	misma_mano = status

func comparar_mesh_en_mano(item_name : String):
	if item_data.nombre == item_name:
		cambiar_status_misma_mano(true)
	else:
		cambiar_status_misma_mano(false)
