extends CharacterBody3D

enum {QUIETO, CAMINAR, INTERACTUAR, SALTAR}
var curAnim = QUIETO

const SPEED = 5.0
const JUMP_VELOCITY = 5.0
@onready var pivot = $CamOrigin
@export var sens = 0.5
@onready var cam = $CamOrigin/SpringArm3D/Camera3D
@onready var joystick_area = $android_gui/JoystickArea
@onready var inventario_area = $android_gui/InventarioArea
@onready var anim_tree = $AnimationTree
@export var blend_speed = 15
@onready var objeto_mano = $Armature/Skeleton3D/BoneAttachment3D/objeto_mano
var update = false
var gt_prev = Transform3D()
var gt_current = Transform3D()
var interpolationActiva = false
var cam_val = 0
var int_val = 0
var sal_val = 0


#var frameSuelo = false # VARIABLES PARA CUANDO BAJA ESCALERAS
#var snapStairs = false

signal action_pressed()

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	# Establece los transform para la interpolación
	gt_prev = global_transform
	gt_current = global_transform
	
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	calidad(calidadManager.idCalidad)
	
	var inventario = get_node("android_gui/ui_inventario/interface_prin/inventario")
	inventario.connect("mesh_emitted", Callable(self, "cargar_mesh"))
	inventario.connect("mesh_changed", Callable(self, "cambiar_mesh"))
	inventario.connect("mesh_removed", Callable(self, "remueve_mesh"))
	

func handle_animation(delta):
	match curAnim:
		QUIETO:
			cam_val = lerpf(cam_val, 0, blend_speed * delta)
			int_val = lerpf(int_val, 0, blend_speed * delta)
			sal_val = lerpf(sal_val, 0, blend_speed * delta)
		CAMINAR:
			cam_val = lerpf(cam_val, 1, blend_speed * delta)
			int_val = lerpf(int_val, 0, blend_speed * delta)
			sal_val = lerpf(sal_val, 0, blend_speed * delta)
		INTERACTUAR:
			cam_val = lerpf(cam_val, 0, blend_speed * delta)
			int_val = lerpf(int_val, 1, blend_speed * delta)
			sal_val = lerpf(sal_val, 0, blend_speed * delta)
		SALTAR:
			cam_val = lerpf(cam_val, 0, blend_speed * delta)
			int_val = lerpf(int_val, 0, blend_speed * delta)
			sal_val = lerpf(sal_val, 1, blend_speed * delta)
	anim_tree["parameters/Caminar/blend_amount"] = cam_val
	anim_tree["parameters/Interactuar/blend_amount"] = int_val
	anim_tree["parameters/Saltar/blend_amount"] = sal_val

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
		if not (joystick_area.get_rect().has_point(event.position) or inventario_area.get_rect().has_point(event.position)):
			# Manejar rotación de cámara si el drag está fuera del área del joystick
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
	# Añadir la gravedad
	if not is_on_floor():
		velocity.y -= gravity * delta
		curAnim = SALTAR
	
	# Botón Acción
	if Input.is_action_just_pressed("ui_home"):
		curAnim = INTERACTUAR
		handle_animation(delta)
		action_pressed.emit()
		
	# Salto
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		curAnim = SALTAR
		audioManager.playSFX("res://sounds/SFX/Salto.wav", -1, 2)
		print("saltando")
		
	# salir con esc
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	
	# Character movement controlled by joystick actions
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		if is_on_floor():
			curAnim = CAMINAR
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		if is_on_floor():
			curAnim = QUIETO
	
	handle_animation(delta)
	move_and_slide()
	#bajarEscaleras()
		
	# Movimiento de la cámara controlado por acciones left, right, up y down
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

#func bajarEscaleras():
#	var did_snap = false
#	if not is_on_floor() and velocity.y <= 0 and (did_snap or snapStairs):
#		var body_test_result = PhysicsTestMotionResult3D.new()
#		var params = PhysicsTestMotionParameters3D.new()
#		var max_step_down = -0.2
		
#		params.from = self.global_transform
#		params.motion = Vector3(0, max_step_down, 0)
#		if PhysicsServer3D.body_test_motion(self.get_rid(), params, body_test_result):
#			var translate_y = body_test_result.get_travel().y
#			self.position.y += translate_y
#			apply_floor_snap()
#	did_snap = is_on_floor()


func _on_item_recolectable_data_emitted(data):
	$android_gui/ui_inventario/interface_prin/inventario.busca_y_set(data)
	
func _on_item_Colocado_Resta_Inventario(item_name):
	$android_gui/ui_inventario/interface_prin/inventario.busca_y_reduce(item_name)

func cargar_mesh(item_data : ItemData):
	var scene_resource = load(item_data.mesh)
	if scene_resource:
		var instance = scene_resource.instantiate()
		instance.name = item_data.nombre
		instance.visible = false
		objeto_mano.add_child(instance)


func cambiar_mesh(item_name : String):
	for objeto in objeto_mano.get_children():
		if objeto.name == item_name:
			objeto.visible = true
			print("mostrando solo", item_name, "/" , objeto.name)
		else:
			objeto.visible = false

func remueve_mesh(item_name : String):
	for objeto in objeto_mano.get_children():
		if objeto.name == item_name:
			objeto.queue_free()
