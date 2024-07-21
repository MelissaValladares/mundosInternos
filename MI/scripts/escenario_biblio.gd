extends Node3D

@onready var botonAction = $main/android_gui/action_button
@onready var botonInfo = $main/android_gui/ControlSuperior/info
@onready var panelScore = $main/android_gui/ControlSuperior/PanelScore
var enRango = false

# Called when the node enters the scene tree for the first time.
func _ready():
	audioManager.playMusica("res://sounds/biblioteca.wav", 0)
	botonAction.visible = false # AL INICIO DE PUEBLO:TSCN ESTÄ OCULTO EL BOTON
	# SI SE QUIERE HACER GLOBAL PARA TODOS LOS ESCENARIOS: SE DEFINE EN STEVE.GD
	$main/android_gui/ControlSuperior/PanelInfo/GridContainer/textMision.text = "Ordena los libros"
	$main/android_gui/ControlSuperior/PanelInfo/GridContainer/statusMision.text = ""
	botonInfo.button_pressed = true
	panelScore.visible = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_main_action_pressed():
	if enRango: # Se puede compara otra variable para saber tipo de accion (SI ES QUE SE USA)
		get_tree().change_scene_to_file("res://pantallaCarga.tscn")


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
