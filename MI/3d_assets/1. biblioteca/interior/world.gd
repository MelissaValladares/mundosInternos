extends MeshInstance3D

var rotation_speed = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(delta):
	# Rotate the node around its Y-axis
	rotate_y(rotation_speed * delta)
