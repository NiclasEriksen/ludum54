extends Node3D

signal game_over


# Called when the node enters the scene tree for the first time.
func _ready():
	var fade_tween: Tween = create_tween()
	fade_tween.tween_property($Control/FadeRect, "color", Color(0,0,0,0), 2.0)
	fade_tween.play()


func _on_ship_died(cause):
	var fade_tween: Tween = create_tween()
	fade_tween.tween_property($Control/FadeRect, "color", Color(0,0,0,1), 1.0)
	fade_tween.play()
	if cause == "crash":
		$Control/CenterContainer/VBoxContainer/Title.text = "Your vessel imploded."
	elif cause == "drowned":
		$Control/CenterContainer/VBoxContainer/Title.text = "Your lungs collapsed."
	Volume.set_volume(-80.0, true)
	$Timer.start()
	$Timer2.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_timer_timeout():
	var fade_tween: Tween = create_tween()
	fade_tween.tween_property($Control/CenterContainer, "modulate", Color(1,1,1,1), 2.0)
	fade_tween.play()
	$Control/CenterContainer.show()


func _on_timer_2_timeout():
	emit_signal("game_over")
