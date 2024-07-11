extends Control

@onready var progreso = []
@onready var statusEscena = 0

func _ready():
	ResourceLoader.load_threaded_request("res://PUEBLO.tscn")

func _process(delta):
	statusEscena = ResourceLoader.load_threaded_get_status("res://PUEBLO.tscn", progreso)
	%ProgressBar.value = progreso[0] * 100
	
	if statusEscena == ResourceLoader.THREAD_LOAD_LOADED:
		await get_tree().create_timer(1.0).timeout
		var escene = ResourceLoader.load_threaded_get("res://PUEBLO.tscn")
		get_tree().change_scene_to_packed(escene)
