extends Node2D

@onready var escenaNota = preload("res://nota.tscn") # Figura NOTA
@onready var escenaLabelNota = preload("res://texto_nota.tscn") # Texto arriba de cada NOTA
@onready var notasEnPartitura = $Notas # COntenedor de todas las notas
@onready var style = $BordeColor.get_theme_stylebox("panel") # Estilo de borde pantalla (BordeColor)

var melodias = preload("res://scripts/melodias.gd").new().melodias # Cargamos array con melodias
var notas
var notaActual = 0 # Contador de NOTA Actual en array
var sound = "" # Tipo de sonido NOTA
var nodosNotas = [] # Las notas cargadas con la dirección de cada nodo creado (COLA)

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

var  coloresLabel = {
	"Do": Color("cfb200"), "Do#": Color("e2a18e"), "Re": Color("ff7ed4"), "Re#": Color("b3a7f3"),
	"Mi": Color("96affe"), "Fa": Color("5cd148"), "Fa#": Color("c3b280"), "Sol": Color("ff8d86"),
	"Sol#": Color("7ec4a2"), "La": Color("2fc2ff"), "La#": Color("c9a5c8"), "Si": Color("eca12e")}

func _ready():
	audioManager.stopMusica()
	cargarNotas()
	$menu.visible = false
	$BordeColor.visible = false
	$ControlSuperior/PanelScore.visible = false
	$ControlSuperior/PanelInfo/GridContainer/statusMision.visible = false
	$ControlSuperior/PanelInfo/GridContainer/textMision.text = "Toca las notas correspondientes"
	$ControlSuperior/PanelInfo.visible = true
	await get_tree().create_timer(2).timeout
	$ControlSuperior/PanelInfo.visible = false

func cargarNotas():
	notas = melodias[GameManager.piezaMusica]
	var n = 0
	var alturaLabel = 17
	
	# Instanciar y colocar las notas
	for i in range(notas.size()):
		if n > 15:
			n = 0

		var nombreNota = notas[i]
		var alturaNota = altura[nombreNota]
		var notaEnCompas = positionCompas[n]
		var nombreNotaCortado = cortarNum(nombreNota) # Nombre visible en JUEGO
		
		if alturaNota > 107: # Cambiamos altura dependiendo si estamos en primer o segundo sistema
			alturaLabel = 315
			
		var notaInstance = escenaNota.instantiate() # CREAMOS NUEVA NOTA
		var labelInstance = escenaLabelNota.instantiate() # CREAMOS LABEL DE ESA NOTA
		
		notaInstance.position = Vector2(notaEnCompas, alturaNota)
		labelInstance.position = Vector2(notaEnCompas, alturaLabel)

		labelInstance.get_node("LabelNota").text = nombreNotaCortado
		labelInstance.get_node("LabelNota").add_theme_stylebox_override("normal", labelReact(nombreNotaCortado))
		
		if nombreNota in ["Do1", "Do2"]:
			notaInstance.get_node("TextureRect").texture = load("res://2d_assets/paper/notaLinea.png")
		elif nombreNota in ["Do#1", "Do#2"]:
			notaInstance.get_node("TextureRect").texture = load("res://2d_assets/paper/notaLineaSostenida.png")
		elif "#" in nombreNota:
			notaInstance.get_node("TextureRect").texture = load("res://2d_assets/paper/notaSostenida.png")
		
		notasEnPartitura.add_child(notaInstance)
		notasEnPartitura.add_child(labelInstance)
		nodosNotas.push_back(labelInstance) # Añadimos la dirección del nodo a la COLA
		n += 1

func avance(isNota):
	if notas[notaActual] == isNota:
		notaActual += 1
		if notaActual >= notas.size():
			audioManager.playSFX("res://sounds/SFX/gameComplete.wav", 0, 2)
			uiReact(0, 0)
			notaActual = 0  # Reinicia la partitura si es necesario
		isNota = cortarNum(isNota)
		sound = "res://sounds/Notas/" + isNota + ".wav"
		audioManager.playSFX(sound, 0, 1)
		uiReact(1, nodosNotas[0])
		return true
	elif notas[notaActual] != isNota:
		uiReact(2, 1)
		return false

func cortarNum(isNota):
	var long = isNota.length()
	
	if long > 0 and isNota[long - 1] in ["1", "2"]:
		return isNota.substr(0, long - 1)
	else:
		return isNota

func uiReact(type, node):
	if type == 0 and node == 0:
		$ControlSuperior.visible = false
		for i in get_tree().get_nodes_in_group("Teclas"):
				i.disabled = true
		if GameManager.piezaMusica == 0:
			$menu.visible = true
			GameManager.piezaMusica = 1
		elif GameManager.piezaMusica == 1:
			$menu.visible = true
			$menu/Titulo.text = "Pieza Completa"
			$menu/Avance.text = "2/3"
			$menu/botonConfirmar.text = "Siguiente Nivel"
			GameManager.piezaMusica = 2
		else: # Ya completó todas las piezas, se repite
			$menu.visible = true
			$menu/Titulo.text = "Clase Concluida"
			$menu/Avance.text = "3/3"
			$menu/botonConfirmar.text = "Finalizar"
			GameManager.piezaMusica = 3
	elif type == 1:
		node.visible = false # Ocultamos el label correcto
		nodosNotas.pop_front() # Lo sacamos de la cola
		style.border_color = Color(0.30, 0.80, 0.45) # CORRECTO = VERDE
		$BordeColor.visible = true
	elif type == 2 and node == 1:
		style.border_color = Color(1, 0.20, 0.20) # INCORRECTO = ROJO
		$BordeColor.visible = true
	await get_tree().create_timer(0.5).timeout
	$BordeColor.visible = false

func labelReact(nombreNota):
	var stylebox = StyleBoxFlat.new()
	stylebox.bg_color = coloresLabel[nombreNota] # Personalizamos Color
	stylebox.set_border_width_all(2)
	stylebox.border_color = Color("ffffff")
	stylebox.set_corner_radius_all(30)
	stylebox.expand_margin_left = 5
	stylebox.expand_margin_right = 5
	return stylebox


func _on_boton_confirmar_pressed():
	if not GameManager.piezaMusica == 3:
		for child in notasEnPartitura.get_children():
			child.queue_free()
		cargarNotas()
		$menu.visible = false
		$ControlSuperior.visible = true
		for i in get_tree().get_nodes_in_group("Teclas"):
				i.disabled = false
	else: # Ya acabó el juego
		GameManager.piezaMusica = 0
		GameManager.add_score()
		get_tree().change_scene_to_file("res://escenario_conservatorio.tscn")

func _on_area_do_input_event(_viewport, event, _shape_idx):
	if event is InputEventScreenTouch and event.pressed:
		if not avance("Do1"):
			avance("Do2")


func _on_area_re_input_event(_viewport, event, _shape_idx):
	if event is InputEventScreenTouch and event.pressed:
		if not avance("Re1"):
			avance("Re2")


func _on_area_doS_input_event(_viewport, event, _shape_idx):
	if event is InputEventScreenTouch and event.pressed:
		if not avance("Do#1"):
			avance("Do#2")


func _on_area_mi_input_event(_viewport, event, _shape_idx):
	if event is InputEventScreenTouch and event.pressed:
		if not avance("Mi1"):
			avance("Mi2")


func _on_area_reS_input_event(_viewport, event, _shape_idx):
	if event is InputEventScreenTouch and event.pressed:
		if not avance("Re#1"):
			avance("Re#2")


func _on_area_fa_input_event(_viewport, event, _shape_idx):
	if event is InputEventScreenTouch and event.pressed:
		if not avance("Fa1"):
			avance("Fa2")


func _on_area_sol_input_event(_viewport, event, _shape_idx):
	if event is InputEventScreenTouch and event.pressed:
		if not avance("Sol1"):
			avance("Sol2")


func _on_area_faS_input_event(_viewport, event, _shape_idx):
	if event is InputEventScreenTouch and event.pressed:
		if not avance("Fa#1"):
			avance("Fa#2")


func _on_area_la_input_event(_viewport, event, _shape_idx):
	if event is InputEventScreenTouch and event.pressed:
		if not avance("La1"):
			avance("La2")


func _on_area_solS_input_event(_viewport, event, _shape_idx):
	if event is InputEventScreenTouch and event.pressed:
		if not avance("Sol#1"):
			avance("Sol#2")


func _on_area_si_input_event(_viewport, event, _shape_idx):
	if event is InputEventScreenTouch and event.pressed:
		if not avance("Si1"):
			avance("Si2")


func _on_area_laS_input_event(_viewport, event, _shape_idx):
	if event is InputEventScreenTouch and event.pressed:
		if not avance("La#1"):
			avance("La#2")
