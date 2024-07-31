extends Area3D
class_name ItemRecolectable
const ROTATION_SPEED = 15
@export var item_data : ItemData
@export var data_receiver : Node = null
signal data_emitted(data: ItemData)
var recolectado : bool = false : set = cambiar_status

func _ready():
	if item_data and item_data.mesh:
		var scene_path = item_data.mesh
		var scene_resource = load(scene_path)
		if scene_resource:
			var instance = scene_resource.instantiate()
			add_child(instance)
		else:
			print("Failed to load scene from path: ", scene_path)
	else:
		print("ItemData or mesh path is not defined")

func _process(delta):
	rotate_y(deg_to_rad(ROTATION_SPEED) * delta)

func _on_body_entered(body):
	if body.name == "main":
		emit_signal("data_emitted", item_data)
		if recolectado:
			audioManager.playSFX("res://sounds/SFX/getTickets.wav", 0, 1)
			queue_free()

func cambiar_status(status : bool):
	recolectado = status
