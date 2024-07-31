extends Node3D

@onready var occluder = $OccluderInstance3D
@onready var botonAction = $main/android_gui/action_button
@onready var botonInfo = $main/android_gui/ControlSuperior/info
@onready var panelScore = $main/android_gui/ControlSuperior/PanelScore
var enRango = false
var juego = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	audioManager.playMusica("res://sounds/Soft.wav", 0)
	GameManager.setCalidad(occluder, calidadManager.idCalidad)
	botonAction.visible = false # AL INICIO DE PUEBLO:TSCN ESTÄ OCULTO EL BOTON
	# SI SE QUIERE HACER GLOBAL PARA TODOS LOS ESCENARIOS: SE DEFINE EN STEVE.GD
	$main/android_gui/ControlSuperior/PanelScore/GridContainer/Score.text = "%d/2" % GameManager.score
	$main/android_gui/ControlSuperior/PanelInfo/GridContainer/textMision.text = "Ve a tocar el piano"
	$main/android_gui/ControlSuperior/PanelInfo/GridContainer/statusMision.text = ""
	botonInfo.button_pressed = true
	panelScore.visible = true


func _on_area_juego_body_entered(body):
	if body.is_in_group("player"):
		enRango = true
		#$main/android_gui/action_button/actionButton.texture_normal = 
		botonAction.visible = true
		juego = "res://gamePiano.tscn"

func _on_area_juego_body_exited(body):
	if body.is_in_group("player"):
		enRango = false
		botonAction.visible = false

func _on_area_composicion_body_entered(body):
	if body.is_in_group("player"):
		enRango = true
		#$main/android_gui/action_button/actionButton.texture_normal = 
		botonAction.visible = true
		juego = "res://composicion_game.tscn"

func _on_area_composicion_body_exited(body):
	if body.is_in_group("player"):
		enRango = false
		botonAction.visible = false


func _on_main_action_pressed(): # Señal que viene de gui_android, botón action
	if enRango:
		get_tree().change_scene_to_file(juego)
