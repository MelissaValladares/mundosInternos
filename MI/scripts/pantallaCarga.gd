extends Control

@onready var progreso = 0
var escena = global.cargarEscena

func _ready():
	call_deferred("carga")

func _process(_delta):
	%ProgressBar.value = progreso * 100

func carga():
	while progreso < 1.0:
		progreso += 0.1
		await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_file(escena)
