extends Control

#Referencia del Lable
@onready var numBoletos = $num
var nivelConcluido = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	numBoletos.text = "x %d/10" % GameManager.score
	#Función para determinar si recogio los boletos
	if not nivelConcluido and puntajeAlcanzado():
		adquirirAudifonos()

func puntajeAlcanzado() -> bool:
	return GameManager.score == 1

func adquirirAudifonos():
	print("Compra audifonos")
	nivelConcluido = true

