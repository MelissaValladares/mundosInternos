extends Area3D

const ROTATION_SPEED = 1;
var nivelConcluido = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#Métododo para rotar
	rotate_y(deg_to_rad(ROTATION_SPEED)*delta)


func _on_body_entered(body):
	if body.name == "main":
		GameManager.add_score()
		queue_free()
		if not nivelConcluido and puntajeAlcanzado():
			adquirirAudifonos()
		
func puntajeAlcanzado() -> bool:
	return GameManager.score == 1
	
func adquirirAudifonos():
	print("Compra audifonos")
	nivelConcluido = true
	$"../Puestos/juguetes/shop/Comprar".disabled=false
	var styleButton = $"../Puestos/juguetes/shop/Comprar".get_theme_stylebox("normal")
	styleButton.bg_color = Color(0.56, 0.68, 0.47)
