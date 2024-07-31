extends Node3D

# Carga de escenas
var cargarEscena = ""
#var action = 0

#Cosas a guardar para almacenar avance de jugador
var escenario = ""
var piezaMusica = 0

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


func saveGame():
	var file = FileAccess.open("user://game.save", FileAccess.WRITE)
	if file:
		var data = {"escenario":escenario,"piezaMusica":piezaMusica}
		var json_string = JSON.stringify(data)
		file.store_line(json_string)
		file.close()

func loadGame():
	if FileAccess.file_exists("user://game.save"):
		var file = FileAccess.open("user://game.save", FileAccess.READ)
		if file:
			var data = file.get_as_text()
			file.close()
			
			var json = JSON.parse_string(data)
			if json:
				escenario = json.get("escenario", true)
				piezaMusica = json.get("piezaMusica", true)
			else:
				print("Error al parsear el archivo JSON:", json.get_error_message())
func save_Escenario_Biblio():
	var file = FileAccess.open("user://escenario_Biblio.json", FileAccess.WRITE)
	if file:
		var data = {
			"state_Escenario_Biblio": state_Escenario_Biblio
			}
		var json_string = JSON.stringify(data)
		file.store_line(json_string)
		file.close()
