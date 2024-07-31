extends PanelContainer

@onready var slots_array = [
	$MarginContainer/GridContainer/slot1, 
	$MarginContainer/GridContainer/slot2,
	$MarginContainer/GridContainer/slot3,
	$MarginContainer/GridContainer/slot4,
	$MarginContainer/GridContainer/slot5]

@export var slot_data_array: Array = []
@export var item_data_empty : ItemData
var curSlot = 0

signal status_emitted(status: bool)
signal mesh_emitted(item_data : ItemData)
signal mesh_changed(item_name : String)
signal mesh_removed(item_name : String)


func initialize_slot_data():
	slot_data_array.resize(5)
	for i in range(5):
		slot_data_array[i] = SlotData.new()
		slot_data_array[i].item_data = item_data_empty

func inventario_disponible() -> bool:
	for slot_data in slot_data_array:
		if slot_data.cantidad == 0:
			return true
	return false

func ultimo_disponible():
	for i in range(5):
		if slot_data_array[i].cantidad == 0:
			return i

func _ready():
	item_data_empty = preload("res://2d_assets/items/empty.tres")
	initialize_slot_data()

func _process(_delta):
	seleccionar()

func seleccionar() -> void:
	if Input.is_action_just_pressed("slot_1"):
		selected_mesh(0)
	if Input.is_action_just_pressed("slot_2"):
		selected_mesh(1)
	if Input.is_action_just_pressed("slot_3"):
		selected_mesh(2)
	if Input.is_action_just_pressed("slot_4"):
		selected_mesh(3)
	if Input.is_action_just_pressed("slot_5"):
		selected_mesh(4)

func selected_mesh(i : int):
	if slot_data_array[i].cantidad !=0:
		emit_signal("mesh_changed", slot_data_array[i].item_data.nombre)
		print("mesh_changed", slot_data_array[i].item_data.nombre)
		

func busca_y_set(data:ItemData):
	for i in range(5):
		if slot_data_array[i].item_data.nombre == data.nombre:
			slot_data_array[i].cantidad += 1
			slots_array[i].etiqueta.text = "x%s" % slot_data_array[i].cantidad
			slots_array[i].etiqueta.show()
			emit_signal("status_emitted", true)
			return
	if inventario_disponible():
		var disponible = ultimo_disponible()
		slot_data_array[disponible].item_data = data
		slot_data_array[disponible].cantidad = 1
		slots_array[disponible].textura.texture = slot_data_array[disponible].item_data.textura
		emit_signal("status_emitted", true)
		emit_signal("mesh_emitted", data)
	else:
		emit_signal("status_emitted", false)

func busca_y_reduce(item_name):
	for i in range(5):
		if slot_data_array[i].item_data.nombre == item_name:
			slot_data_array[i].cantidad -=1
			if slot_data_array[i].cantidad >= 1 :
				slots_array[i].etiqueta.text = "x%s" % slot_data_array[i].cantidad
				slots_array[i].etiqueta.show()
			else:
				slots_array[i].etiqueta.hide()
				slots_array[i].textura.texture = null
				slot_data_array[i].item_data = item_data_empty
				emit_signal("mesh_removed", item_name)
			return
