extends OmniLight3D
@export var on_material: StandardMaterial3D
@export var off_material: StandardMaterial3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func turn_on():
	light_energy = 1.0
	$MeshInstance3D.set_surface_override_material(0, on_material)

func turn_off():
	light_energy = 0.0
	$MeshInstance3D.set_surface_override_material(0, off_material)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
