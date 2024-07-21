extends Node3D

#Número de boletos adquiridos
var score = 0;
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
 
#Función para aumentar el num. de boletos
func add_score():
	score += 1;
