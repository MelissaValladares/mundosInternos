extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 5.0
@onready var pivot = $CamOrigin
@export var sens = 0.5
@onready var cam = $CamOrigin/SpringArm3D/Camera3D
@onready var joystick_area = $android_gui/JoystickArea
#@onready var personaje = $personaje/AnimationPlayer/AnimationTree.get("parameters/playback")

var update = false
var gt_prev = Transform3D()
var gt_current = Transform3D()
var interpolationActiva = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	# Establece los transform para la interpolación
	gt_prev = global_transform
	gt_current = global_transform
	
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	calidad(calidadManager.idCalidad)
	
func calidad(tipo):
	match tipo:
		0:  # Baja calidad
			cam.far = 50.0
			interpolationActiva = false
		1:  # Media calidad
			cam.far = 100.0
			interpolationActiva = true
		2:  # Alta calidad
			cam.far = 200.0
			interpolationActiva = true
		_:
			print("Tipo calidad no reconocido ", tipo)
	print("Cam far actualizado a: ", cam.far, " | Interpolación: ", interpolationActiva)

func _input(event):
	if event is InputEventScreenDrag:
		if not joystick_area.get_rect().has_point(event.position):
			# Handle camera rotation if the drag is outside the joystick area
			rotate_y(deg_to_rad(-event.relative.x * sens))
			pivot.rotate_x(deg_to_rad(-event.relative.y * sens))
			pivot.rotation.x = clamp(pivot.rotation.x, deg_to_rad(-90), deg_to_rad(45))

@warning_ignore("unused_parameter")
func _process(delta):
	if update:
		update_transform()
		update = false
	if interpolationActiva:
		var f = clamp(Engine.get_physics_interpolation_fraction(), 0, 1)
		global_transform = gt_prev.interpolate_with(gt_current, f)

func _physics_process(delta):
	update = true
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# salto.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#personaje.travel("Saltar")
		velocity.y = JUMP_VELOCITY
	# salir con esc
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	
	# Character movement controlled by joystick actions
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		#personaje.travel("Caminar")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		#personaje.travel("Quieto")
	move_and_slide()
	
	# Camera movement controlled by left, right, up, and down actions
	var camera_dir = Vector2.ZERO
	if Input.is_action_pressed("char_left"):
		camera_dir.x -= 1
	if Input.is_action_pressed("char_right"):
		camera_dir.x += 1
	if Input.is_action_pressed("char_up"):
		camera_dir.y -= 1
	if Input.is_action_pressed("char_down"):
		camera_dir.y += 1
	
	if camera_dir != Vector2.ZERO:
		rotate_y(deg_to_rad(camera_dir.x * sens))
		pivot.rotate_x(deg_to_rad(camera_dir.y * sens))
		pivot.rotation.x = clamp(pivot.rotation.x, deg_to_rad(-90), deg_to_rad(45))
	
	# Guardar el estado actual del transform para la interpolación
	gt_prev = gt_current
	gt_current = global_transform

func update_transform():
	gt_prev = gt_current
	gt_current = global_transform
	
	
#func stateMachine():
#	match personaje.get_current_node():
#		"Caminar":
#			personaje.travel("Jump")
#		"Quieto":
#			personaje.travel("Jump")
