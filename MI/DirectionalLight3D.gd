extends DirectionalLight3D

@export var rotation_speed: float = 10.0
@export var max_intensity: float = 1.0
@export var min_intensity: float = 0.1
@export var day_color: Color = Color(1.0, 1.0, 1.0)
@export var night_color: Color = Color(0.1, 0.1, 0.5)

# Declare the light intensity as a property
@export var light_intensity: float = 1.0

func _ready():
	# Ensure the light starts with a specific rotation and intensity
	rotation_degrees.x = 45.0
	light_intensity = max_intensity

func _process(delta):
	# Rotate the light around the X-axis to simulate time passing
	rotation_degrees.x += rotation_speed * delta
	if rotation_degrees.x >= 360.0:		rotation_degrees.x -= 360.0

	# Calculate the normalized time of day (0.0 to 1.0)
	var time_of_day = fmod(rotation_degrees.x, 360.0) / 360.0
	
	# Adjust intensity based on time of day (simple sine wave for day-night cycle)
	light_intensity = lerp(min_intensity, max_intensity, max(0, sin(time_of_day * PI)))
	
	# Adjust color based on time of day
	light_color = day_color.lerp(night_color, abs(sin(time_of_day * PI)))
