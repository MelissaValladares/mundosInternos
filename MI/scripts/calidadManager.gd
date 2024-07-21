extends Node

var idCalidad = 0

func _ready():
	loadConfigGraficos()

func setCalidad(index):
	idCalidad = index
	saveConfigGraficos()


###### CONFIGURACIÓN #######
func saveConfigGraficos():
	var file = FileAccess.open("user://settingsGraficos.save", FileAccess.WRITE)
	if file:
		var data = {"calidad":idCalidad}
		var json_string = JSON.stringify(data)
		file.store_line(json_string)
		file.close()

func loadConfigGraficos():
	if FileAccess.file_exists("user://settingsGraficos.save"):
		var file = FileAccess.open("user://settingsGraficos.save", FileAccess.READ)
		if file:
			var data = file.get_as_text()
			file.close()
			
			var json = JSON.parse_string(data)
			if json:
				var result = json.get("calidad", 0)
				idCalidad = type_convert(result, TYPE_INT)
				setCalidad(idCalidad)
			else:
				print("Error al parsear el archivo JSON:", json.get_error_message())
	else:
		setCalidad(idCalidad)
