extends Camera3D

var decay = 0.8
var max_offset = Vector2(0.025, 0.015)
var max_roll = 0.05

var trauma = 0.0
var trauma_power = 2


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()


func add_trauma(force: float) -> void:
	trauma = min(trauma + force, 1.0)

func shake() -> void:
	var amount = pow(trauma, trauma_power)
	rotation.z = max_roll * amount * randf_range(-1, 1)
	h_offset = max_offset.x * amount * randf_range(-1, 1)
	v_offset = max_offset.y * amount * randf_range(-1, 1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	trauma = max(trauma - decay * delta, 0)
	shake()
