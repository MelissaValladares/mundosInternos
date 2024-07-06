extends Node3D

@onready var occluder = $OccluderInstance3D

func _ready():
	setCalidad(calidadManager.idCalidad)

func setCalidad(i):
	match i:
		0:  # Baja calidad
			occluder.visible = false  # Ejemplo: ocultar el occluderInstance
		1:  # Media calidad
			occluder.visible = false  # Ejemplo: mostrar el occluderInstance
		2:  # Alta calidad
			occluder.visible = true  # Ejemplo: mostrar el occluderInstance
		_:
			print("Tipo calidad no reconocido", i)
	print("occluder actualizado a:", occluder)

#func _process(delta):
#	pass
