extends CanvasLayer

@onready var cerrar = $Button

# Called when the node enters the scene tree for the first time.
func _ready():
	cerrar.focus_mode = Control.FOCUS_NONE
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	get_node("AnimationPlayer").play("TOUT")
