extends Area3D

@export var highlight_mesh1: MeshInstance3D
@export var highlight_mesh2: MeshInstance3D
@export var regular_material: StandardMaterial3D
@export var highlight_material: StandardMaterial3D
@export var tip_label: NodePath
var tip_shown: bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func highlight(state: bool) -> void:
	if state:
		if not tip_shown and tip_label != null:
#			tip_shown = true
			get_node(tip_label).show()
		if highlight_mesh1 != null:
			highlight_mesh1.set_surface_override_material(0, highlight_material)
		if highlight_mesh2 != null:
			highlight_mesh2.set_surface_override_material(0, highlight_material)
	else:
		if tip_label != null and tip_shown:
			get_node(tip_label).hide()
		if highlight_mesh1 != null:
			highlight_mesh1.set_surface_override_material(0, regular_material)
		if highlight_mesh2 != null:
			highlight_mesh2.set_surface_override_material(0, regular_material)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
