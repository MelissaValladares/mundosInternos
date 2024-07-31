extends Node3D

# Carga de escenas
var cargarEscena = ""
var action = 0

# Número de boletos adquiridos
var score = 0;
var items_Recolectable_Array : Array
var spots_Receptores_Array : Array
enum state_Escenario_Biblio {pre, cur, post}


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
 
#Función para aumentar el num. de boletos
func add_score():
	score += 1;

func save_Escenario_Biblio():
	var file = FileAccess.open("user://escenario_Biblio.json", FileAccess.WRITE)
	if file:
		var data = {
			"state_Escenario_Biblio": state_Escenario_Biblio
			}
		var json_string = JSON.stringify(data)
		file.store_line(json_string)
		file.close()
