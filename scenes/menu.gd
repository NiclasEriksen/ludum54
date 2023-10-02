extends Control


signal new_game


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel") and get_tree().paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		get_tree().paused = false
		hide()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel") and visible:
		get_tree().quit()


func _on_new_button_pressed():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false
	emit_signal("new_game")


func _on_volume_slider_value_changed(value):
	Volume.set_custom_volume(linear_to_db(value))


func _on_quit_button_pressed():
	get_tree().quit()
