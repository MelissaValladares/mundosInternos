extends Node3D

@onready var occluder = $OccluderInstance3D
@onready var botonVisible = $main/android_gui/action_button # BOTON DE ACCION
@onready var botonInfo = $main/android_gui/ControlSuperior/info
@onready var panelScore = $main/android_gui/ControlSuperior/PanelScore
var enRango = false

func _ready():
	setCalidad(calidadManager.idCalidad)
	botonVisible.visible = false # AL INICIO DE PUEBLO:TSCN ESTÄ OCULTO EL BOTON
	# SI SE QUIERE HACER GLOBAL PARA TODOS LOS ESCENARIOS: SE DEFINE EN STEVE.GD
	$main/android_gui/ControlSuperior/PanelInfo/GridContainer/textMision.text = "Ve a la biblioteca"
	$main/android_gui/ControlSuperior/PanelInfo/GridContainer/statusMision.text = ""
	botonInfo.button_pressed = true
	panelScore.visible = false
  
func setCalidad(i):
	match i:
		0:  # Baja calidad
			occluder.visible = false  # Ejemplo: ocultar el occluderInstance
		1:  # Media calidad  
			occluder.visible = false  # Ejemplo: mostrar el occluderInstance
		2:  # Alta calidad
			occluder.visible = true  # Ejemplo: mostrar el occluderInstance
		_:
			print("Tipo calidad no reconocido", i)
	print("occluder actualizado a:", occluder)

#func _process(delta):
#	pass


func _on_main_action_pressed(): # Señal que viene de gui_android, botón action
	if enRango: # Se puede compara otra variable para saber tipo de accion (SI ES QUE SE USA)
		get_tree().change_scene_to_file("res://pantallaCarga.tscn") # Acción: entrar a nivel



func _on_area_biblio_body_entered(body):
	if body.is_in_group("player"):
		global.cargarEscena = "res://escenario_biblio.tscn"
		enRango = true
		# Si se requiere otra variable para ver tipo de acción va aquí
		var texture = load("res://2d_assets/puerta/puerta.png")
		$main/android_gui/action_button/actionButton.texture_normal = texture
		botonVisible.visible = true
		
func _on_area_biblio_body_exited(body):
	if body.is_in_group("player"):
		enRango = false
		botonVisible.visible = false

func _on_area_conser_body_entered(body):
	if body.is_in_group("player"):
		global.cargarEscena = "res://escenario_conservatorio.tscn"
		enRango = true
		# Si se requiere otra variable para ver tipo de acción va aquí
		var texture = load("res://2d_assets/puerta/puerta.png")
		$main/android_gui/action_button/actionButton.texture_normal = texture
		botonVisible.visible = true

func _on_area_conser_body_exited(body):
	if body.is_in_group("player"):
		enRango = false
		botonVisible.visible = false
