extends PanelContainer

const Slot = preload("res://slot.tscn")
@onready var grid = $MarginContainer/GridContainer

#func _ready() ->void:
#	var inv_data = preload("res://inventario_test.tres")
#	llenar_grid(inv_data.slot_datas)

func llenar_grid(slot_datas:Array[SlotData]) -> void:
	for child in grid.get_children():
		child.queue_free()
	
	for slot_data in slot_datas:
		var slot = Slot.instantiate()
		grid.add_child(slot)
		
		if slot_data :
			slot.set_slot_data(slot_data)
