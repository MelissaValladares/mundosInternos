extends Node2D

@onready var escenaNota = preload("res://nota.tscn")
@onready var notasEnPartitura = $Notas # COntenedor de todas las notas

var nodosNotas = []
var n = 0
var m = "1"

var positionCompas = [
	302,
	390, # +88
	478,
	566, # FIN PRIMER COMPÁS +135
	701, # compás 2
	789,
	877,
	965, # FIN SEGUNDO COMPÁS +135
	1070, # com 3
	1158,
	1246,
	1334, # FIN TERCER COMPÁS +135 AJUSTADO MANUALMENTE
	1469, # com 4
	1557,
	1645,
	1733 # FIN CUARTO COMPÁS
]

var altura = {
	"Do1": 107, "Do#1": 107, "Re1": 97, "Re#1": 97,
	"Mi1": 87, "Fa1": 75, "Fa#1": 75, "Sol1": 63,
	"Sol#1": 63, "La1": 50, "La#1": 50, "Si1": 38,
	# SEGUNDO SISTEMA
	"Do2": 407, "Do#2": 407, "Re2": 397, "Re#2": 397, 
	"Mi2": 387, "Fa2": 375, "Fa#2": 375, "Sol2": 363,
	"Sol#2": 363, "La2": 350, "La#2": 350, "Si2": 338 }


func _ready():
	audioManager.stopMusica()
	$menu.visible = false
	$ControlSuperior/PanelScore.visible = false
	$ControlSuperior/PanelInfo/GridContainer/statusMision.visible = false
	$ControlSuperior/PanelInfo/GridContainer/textMision.text = "Crea tu propia melodía"
	$ControlSuperior/PanelInfo.visible = true
	await get_tree().create_timer(2).timeout
	$ControlSuperior/PanelInfo.visible = false

func _process(_delta):
	if nodosNotas.is_empty():
		$Madera/botonDelete.visible = false
		$Madera/LabelDelete.visible = false
		$Madera/botonComplete.visible = false
		$Madera/LabelComplete.visible = false
	elif nodosNotas.size() == 32:
		for i in get_tree().get_nodes_in_group("Teclas"):
				i.disabled = true
		$Madera/botonComplete.visible = true
		$Madera/LabelComplete.visible = true		
	else:
		$Madera/botonComplete.visible = false
		$Madera/LabelComplete.visible = false
		$Madera/botonDelete.visible = true
		$Madera/LabelDelete.visible = true

func addNota(nota):
	if nodosNotas.size() > 31:
		return
	elif nodosNotas.size() > 15:
		n = nodosNotas.size() - 16
		m = "2"
	else:
		n = nodosNotas.size()
		m = "1"
	
	var notaS = nota + m
	var alturaNota = altura[notaS]
	var notaEnCompas = positionCompas[n]
	#var nombreNotaCortado = cortarNum(nombreNota) # Nombre visible en JUEGO
		
	#if alturaNota > 107: # Cambiamos altura dependiendo si estamos en primer o segundo sistema
	#	alturaLabel = 315
			
	var notaInstance = escenaNota.instantiate() # CREAMOS NUEVA NOTA
	#var labelInstance = escenaLabelNota.instantiate() # CREAMOS LABEL DE ESA NOTA
		
	notaInstance.position = Vector2(notaEnCompas, alturaNota)
	#labelInstance.position = Vector2(notaEnCompas, alturaLabel)

	#labelInstance.get_node("LabelNota").text = nombreNotaCortado
	#labelInstance.get_node("LabelNota").add_theme_stylebox_override("normal", labelReact(nombreNotaCortado))
		
	if notaS in ["Do1", "Do2"]:
		notaInstance.get_node("TextureRect").texture = load("res://2d_assets/paper/notaLinea.png")
	elif notaS in ["Do#1", "Do#2"]:
		notaInstance.get_node("TextureRect").texture = load("res://2d_assets/paper/notaLineaSostenida.png")
	elif "#" in notaS:
		notaInstance.get_node("TextureRect").texture = load("res://2d_assets/paper/notaSostenida.png")
		
	notasEnPartitura.add_child(notaInstance)
	#notasEnPartitura.add_child(labelInstance)
	var notaData = {
		"instance": notaInstance,
		"nota": nota
	}
	nodosNotas.push_back(notaData) # Añadimos la dirección del nodo a la COLA
	n += 1


func _on_boton_delete_pressed():
	if nodosNotas.size() == 32:
		for i in get_tree().get_nodes_in_group("Teclas"):
				i.disabled = false
	var a = nodosNotas.back()
	a["instance"].queue_free()
	nodosNotas.pop_back()

func _on_boton_complete_pressed():
	$menu.visible = true
	$ControlSuperior.visible = false
	audioManager.playSFX("res://sounds/SFX/gameComplete.wav", 0, 2)

func _on_boton_escuchar_pressed():
	$menu/botonEscuchar.disabled = true
	for sonido in nodosNotas:
		var sound = "res://sounds/Notas/" + sonido["nota"] + ".wav"
		audioManager.playSFX(sound, 0, 1)
		await get_tree().create_timer(0.5).timeout
	$menu/botonEscuchar.disabled = false
	$menu/botonEscuchar.text = "Escuchar de nuevo"

func _on_boton_salir_pressed():
	GameManager.add_score()
	get_tree().change_scene_to_file("res://escenario_conservatorio.tscn")



func _on_area_do_input_event(_viewport, event, _shape_idx):
	if event is InputEventScreenTouch and event.pressed:
		addNota("Do")
		audioManager.playSFX("res://sounds/Notas/Do.wav", 0, 1)

func _on_area_re_input_event(_viewport, event, _shape_idx):
	if event is InputEventScreenTouch and event.pressed:
		addNota("Re")
		audioManager.playSFX("res://sounds/Notas/Re.wav", 0, 1)

func _on_area_doS_input_event(_viewport, event, _shape_idx):
	if event is InputEventScreenTouch and event.pressed:
		addNota("Do#")
		audioManager.playSFX("res://sounds/Notas/Do#.wav", 0, 1)

func _on_area_mi_input_event(_viewport, event, _shape_idx):
	if event is InputEventScreenTouch and event.pressed:
		addNota("Mi")
		audioManager.playSFX("res://sounds/Notas/Mi.wav", 0, 1)

func _on_area_reS_input_event(_viewport, event, _shape_idx):
	if event is InputEventScreenTouch and event.pressed:
		addNota("Re#")
		audioManager.playSFX("res://sounds/Notas/Re#.wav", 0, 1)

func _on_area_fa_input_event(_viewport, event, _shape_idx):
	if event is InputEventScreenTouch and event.pressed:
		addNota("Fa")
		audioManager.playSFX("res://sounds/Notas/Fa.wav", 0, 1)

func _on_area_sol_input_event(_viewport, event, _shape_idx):
	if event is InputEventScreenTouch and event.pressed:
		addNota("Sol")
		audioManager.playSFX("res://sounds/Notas/Sol.wav", 0, 1)

func _on_area_faS_input_event(_viewport, event, _shape_idx):
	if event is InputEventScreenTouch and event.pressed:
		addNota("Fa#")
		audioManager.playSFX("res://sounds/Notas/Fa#.wav", 0, 1)

func _on_area_la_input_event(_viewport, event, _shape_idx):
	if event is InputEventScreenTouch and event.pressed:
		addNota("La")
		audioManager.playSFX("res://sounds/Notas/La.wav", 0, 1)

func _on_area_solS_input_event(_viewport, event, _shape_idx):
	if event is InputEventScreenTouch and event.pressed:
		addNota("Sol#")
		audioManager.playSFX("res://sounds/Notas/Sol#.wav", 0, 1)

func _on_area_si_input_event(_viewport, event, _shape_idx):
	if event is InputEventScreenTouch and event.pressed:
		addNota("Si")
		audioManager.playSFX("res://sounds/Notas/Si.wav", 0, 1)

func _on_area_laS_input_event(_viewport, event, _shape_idx):
	if event is InputEventScreenTouch and event.pressed:
		addNota("La#")
		audioManager.playSFX("res://sounds/Notas/La#.wav", 0, 1)
