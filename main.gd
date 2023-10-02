extends Node3D

@export var world_scene: PackedScene = preload("res://scenes/world/world.tscn")
@export var world_path: NodePath = "world"
var world: Node = null

# Called when the node enters the scene tree for the first time.
func _ready():
#	get_tree().paused = true
	pass


func restart_game():
	Volume.set_volume(-80)
	if world != null:
		world.free()
	world = world_scene.instantiate()
	var _c = world.connect("game_over", self._on_game_over)
	add_child(world)
	$Menu.hide()
	Volume.set_volume(Volume.custom_level, true)


func _on_game_over() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true
	$Menu.show()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().paused = true
		$Menu.show()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_menu_new_game():
	restart_game()
