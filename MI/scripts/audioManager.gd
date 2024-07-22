extends Node

var musicPlayer: AudioStreamPlayer
var sfxPlayer: AudioStreamPlayer
var sfxPlayer2: AudioStreamPlayer
var SFX = true
var musica = true

func _ready():
	# Crear y configurar el nodo AudioStreamPlayer
	musicPlayer = AudioStreamPlayer.new()
	sfxPlayer = AudioStreamPlayer.new()
	sfxPlayer2 = AudioStreamPlayer.new()
	add_child(musicPlayer)
	add_child(sfxPlayer)
	add_child(sfxPlayer2)
	
	# Cargar configuraciones
	loadConfigAudio()

func playMusica(audioPath: String, volume_db: float):
	if musica:
		var audioStream = load(audioPath)
		if audioStream is AudioStream:
			musicPlayer.stream = audioStream
			musicPlayer.volume_db = volume_db
			musicPlayer.play()
		else:
			print("Error: No se pudo cargar el archivo")
	else:
		print("La música está deshabilitada")

func stopMusica():
	musicPlayer.stop()

func playSFX(audioPath: String, volume_db: float, chanel: int):
	if SFX:
		var audioStream = load(audioPath)
		if audioStream is AudioStream:
			if chanel == 1:
				sfxPlayer.stream = audioStream
				sfxPlayer.volume_db = volume_db
				sfxPlayer.play()
			else:
				sfxPlayer2.stream = audioStream
				sfxPlayer2.volume_db = volume_db
				sfxPlayer2.play()
		else:
			print("Error: No se pudo cargar el archivo de efecto de sonido")

func SFXStatus(status: bool):
	SFX = status
	saveConfigAudio()

func musicaStatus(status: bool):
	musica = status
	saveConfigAudio()

###### CONFIGURACIÓN #######
func saveConfigAudio():
	var file = FileAccess.open("user://settingsAudio.save", FileAccess.WRITE)
	if file:
		var data = {"sfxEnabled":SFX,"musicaEnabled":musica}
		var json_string = JSON.stringify(data)
		file.store_line(json_string)
		file.close()

func loadConfigAudio():
	if FileAccess.file_exists("user://settingsAudio.save"):
		var file = FileAccess.open("user://settingsAudio.save", FileAccess.READ)
		if file:
			var data = file.get_as_text()
			file.close()
			
			var json = JSON.parse_string(data)
			if json:
				SFX = json.get("sfxEnabled", true)
				musica = json.get("musicaEnabled", true)
			else:
				print("Error al parsear el archivo JSON:", json.get_error_message())
