extends Control

@export var PopUpSalida: PanelContainer
@export var PopUpConfiguracion: PanelContainer
@export var botonConfig: Button


# CARGA ESCENA
func _ready():
	PopUpSalida.visible = false
	PopUpConfiguracion.visible = false
	
	$PopUpConfiguracion/GridContainer/VBoxContainer/SonidosCheck.button_pressed = audioManager.SFX
	$PopUpConfiguracion/GridContainer/VBoxContainer/MusicaCheck.button_pressed = audioManager.musica
	$PopUpConfiguracion/GridContainer/VBoxContainer/VBoxContainer/OptionButton.select(calidadManager.idCalidad)
	
	audioManager.playMusica("res://sounds/MenuPrincipal.wav", -12)

func _on_iniciar_pressed():
	get_tree().change_scene_to_file("res://PUEBLO.tscn")

func _on_salir_pressed():
	PopUpSalida.visible = true
	botonConfig.visible = false

func _on_confirmar_salida_pressed():
	get_tree().quit()

func _on_denegar_salida_pressed():
	PopUpSalida.visible = false
	botonConfig.visible = true

########  SECCIÓN CONFIGURACIÓN  ########
func _on_boton_config_pressed():
	botonConfig.visible = false
	PopUpConfiguracion.visible = true

func _on_okey_pressed():
	botonConfig.visible = true
	PopUpConfiguracion.visible = false

######## SONIDO ###########
func _on_sonidos_check_toggled(toggled_on):
	audioManager.SFXStatus(toggled_on)

######## MÚSICA ###########
func _on_musica_check_toggled(toggled_on):
	audioManager.musicaStatus(toggled_on)
	if toggled_on:
		if not audioManager.musicPlayer.playing:
			audioManager.playMusica("res://sounds/MenuPrincipal.wav", -12)
	else:
		if audioManager.musicPlayer.playing:
			audioManager.stopMusica()

func _on_option_button_item_selected(index):
	calidadManager.setCalidad(index)
	
####CONFIGURACION TOUCH MÓVIL#####
# Manejo de eventos de entrada (táctiles y clics de ratón)
func _input(event):
	if event is InputEventScreenTouch:
		if event.is_pressed():
			var touch_position = event.position
			# Itera sobre todos los nodos hijos
			for node in get_children():
				if node is Button:
					var button = node as Button
					# Verifica si el botón está visible y fue tocado
					if button.visible && button.rect_abs.has_point(touch_position):
						button.pressed = true  # Simula que se presionó el botón
						return
