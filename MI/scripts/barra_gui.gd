extends Control

@onready var PanelInfo = $PanelInfo
@onready var PanelPausa = $PanelPausa
@onready var PanelScore = $PanelScore
@onready var info = $info
@onready var pause = $pause

#Aquí también se controlan los textos

func _ready():
	PanelInfo.visible = false
	PanelPausa.visible = false
	
	# Deshabilitar navegación por teclado para botones
	info.focus_mode = Control.FOCUS_NONE
	pause.focus_mode = Control.FOCUS_NONE

func _on_info_toggled(toggled_on):
	PanelInfo.visible = toggled_on

func _on_pause_pressed():
	PanelPausa.visible = true
	get_tree().paused = not get_tree().paused
	
func _on_salir_menu_pressed():
	audioManager.stopMusica()
	get_tree().paused = false
	global.cargarEscena = "res://menu.tscn"
	get_tree().change_scene_to_file("res://pantallaCarga.tscn")


func _on_regresar_juego_pressed():
	PanelPausa.visible = false
	get_tree().paused = not get_tree().paused

# Manejo de eventos de entrada (táctiles y clics de ratón)
#func _input(event):
#    if event is InputEventScreenTouch:
#        if event.is_pressed():
 #           var touch_position = event.position
 #           # Itera sobre todos los nodos hijos
 #           for node in get_children():
 #               if node is Button:
 #                   var button = node as Button
  #                  # Verifica si el botón está visible y fue tocado
 #                   if button.visible and button.get_global_rect().has_point(touch_position):
  #                      button.press()  # Simula que se presionó el botón
 #                       return
 #               elif node is CheckButton:
 #                   var check_button = node as CheckButton
 #                   # Verifica si el botón está visible y fue tocado
 #                   if check_button.visible and check_button.get_global_rect().has_point(touch_position):
 #                       check_button.pressed = !check_button.pressed  # Alterna el estado del CheckButton
 #                       return
