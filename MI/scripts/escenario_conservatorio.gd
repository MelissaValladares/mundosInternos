extends Node3D

@onready var botonAction = $main/android_gui/action_button
@onready var botonInfo = $main/android_gui/ControlSuperior/info
@onready var panelScore = $main/android_gui/ControlSuperior/PanelScore
var enRango = false

# Called when the node enters the scene tree for the first time.
func _ready():
	audioManager.playMusica("res://sounds/Soft.wav", 0)
	botonAction.visible = false # AL INICIO DE PUEBLO:TSCN ESTÄ OCULTO EL BOTON
	# SI SE QUIERE HACER GLOBAL PARA TODOS LOS ESCENARIOS: SE DEFINE EN STEVE.GD
	$main/android_gui/ControlSuperior/PanelInfo/GridContainer/textMision.text = "Ve a tocar el piano"
	$main/android_gui/ControlSuperior/PanelInfo/GridContainer/statusMision.text = ""
	botonInfo.button_pressed = true
	panelScore.visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
