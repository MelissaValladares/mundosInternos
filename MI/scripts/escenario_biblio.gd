extends Node3D

@onready var botonAction = $main/android_gui/action_button
@onready var botonInfo = $main/android_gui/ControlSuperior/info
@onready var panelScore = $main/android_gui/ControlSuperior/PanelScore
var enRango = false

@onready var main = $main

@onready var rayo = $main/CamOrigin/SpringArm3D/Camera3D/RayCast3D
var prev_Obj_Col = null
var obj_Col = null
var item_Col_En_Spot : bool = false : set = set_Item_Col_En_Spot
signal item_Colocado_Resta_Inventario(item_name : String)

# Called when the node enters the scene tree for the first time.
func _ready():
	audioManager.playMusica("res://sounds/biblioteca.wav", 0)
	botonAction.visible = false # AL INICIO DE PUEBLO:TSCN ESTÄ OCULTO EL BOTON
	# SI SE QUIERE HACER GLOBAL PARA TODOS LOS ESCENARIOS: SE DEFINE EN STEVE.GD
	$main/android_gui/ControlSuperior/PanelInfo/GridContainer/textMision.text = "Ordena los libros"
	$main/android_gui/ControlSuperior/PanelInfo/GridContainer/statusMision.text = ""
	botonInfo.button_pressed = true
	panelScore.visible = true
	var inventario = get_node("main/android_gui/ui_inventario/interface_prin/inventario")
	var items = get_node("items_recolectables")
	for item in items.get_children():
		if item is ItemRecolectable:
			inventario.connect("status_emitted", Callable(item, "cambiar_status"))
	var spots = get_node("spots_receptores")
	for spot in spots.get_children():
		if spot is SpotReceptor:
			inventario.connect("mesh_changed", Callable(spot, "comparar_mesh_en_mano"))
	self.connect("item_Colocado_Resta_Inventario", Callable(inventario, "busca_y_reduce"))

func _process(delta):
	busca_slot()

func _on_main_action_pressed():
	if enRango: # Se puede compara otra variable para saber tipo de accion (SI ES QUE SE USA)
		get_tree().change_scene_to_file("res://pantallaCarga.tscn")
	if item_Col_En_Spot:
		emit_signal("item_Colocado_Resta_Inventario", obj_Col.item_data.nombre)
		obj_Col.cambiar_status_lleno(true)
		botonAction.visible = false
		

func _on_area_biblio_body_entered(body):
	if body.is_in_group("player"):
		GameManager.cargarEscena = "res://PUEBLO.tscn"
		enRango = true
		# Si se requiere otra variable para ver tipo de acción va aquí
		var texture = load("res://2d_assets/puerta/puerta.png")
		$main/android_gui/action_button/actionButton.texture_normal = texture
		botonAction.visible = true


func _on_area_biblio_body_exited(body):
	if body.is_in_group("player"):
		enRango = false
		botonAction.visible = false


func busca_slot():
	if rayo.is_colliding():
		obj_Col = rayo.get_collider()
		if obj_Col.is_in_group("slot_interctuable"):
			if prev_Obj_Col and prev_Obj_Col != obj_Col:
				prev_Obj_Col.cambiar_status_seleccionado(false)
			obj_Col.cambiar_status_seleccionado(true)
			prev_Obj_Col = obj_Col
			if obj_Col.misma_mano and not obj_Col.lleno:
				var texture = load("res://2d_assets/action/action.png")
				$main/android_gui/action_button/actionButton.texture_normal = texture
				botonAction.visible = true
				set_Item_Col_En_Spot(true)
	else:
		if prev_Obj_Col:
			prev_Obj_Col.cambiar_status_seleccionado(false)
			prev_Obj_Col = null
			botonAction.visible = false
			set_Item_Col_En_Spot(false)

func set_Item_Col_En_Spot(status : bool):
	item_Col_En_Spot = status

