extends PanelContainer
@onready var texture_rect = $MarginContainer/TextureRect
@onready var cantidad_etiqueta = $cantidad_etiqueta



func set_slot_data(slot_data: SlotData) -> void:
	var item_data = slot_data.item_data
	texture_rect.texture = item_data.texture
	tooltip_text = "%s\n" % [item_data.nombre, item_data.descripcion]
	if slot_data.cantidad > 1:
		cantidad_etiqueta.text = "x%s" % slot_data.cantidad
		cantidad_etiqueta.show()


