extends Node3D

@onready var botonAction = $main/android_gui/action_button
@onready var botonInfo = $main/android_gui/ControlSuperior/info
@onready var panelScore = $main/android_gui/ControlSuperior/PanelScore
@onready var cerrar = $Puestos/juguetes/shop/Button

var enRango = false

# Called when the node enters the scene tree for the first time.
func _ready():
	audioManager.playMusica("res://sounds/Feria.wav", 0)
	botonAction.visible = false # AL INICIO DE PUEBLO:TSCN ESTÄ OCULTO EL BOTON
	# SI SE QUIERE HACER GLOBAL PARA TODOS LOS ESCENARIOS: SE DEFINE EN STEVE.GD
	$main/android_gui/ControlSuperior/PanelInfo/GridContainer/textMision.text = "Recoge las monedas"
	$main/android_gui/ControlSuperior/PanelInfo/GridContainer/statusMision.text = ""
	$main/android_gui/ControlSuperior/PanelScore/GridContainer/textoScore.text = "Boletos"
	$Puestos/juguetes/shop.hide()
	$Puestos/juguetes/shop/Comprar.disabled = true; 
	botonInfo.button_pressed = true
	panelScore.visible = true
	cerrar.focus_mode = Control.FOCUS_NONE


func _process(delta):
	$main/android_gui/ControlSuperior/PanelScore/GridContainer/Score.text = "%d/10" % GameManager.score
	

func _on_area_biblio_body_entered(body):
	if body.name == "main":
		get_node("Puestos/juguetes/shop/AnimationPlayer").play("TIN")
		$Puestos/juguetes/shop.show()
		

func _on_button_pressed():
	$Puestos/juguetes/shop/AnimationPlayer.play("TOUT")
