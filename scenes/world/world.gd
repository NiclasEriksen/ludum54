extends Node3D

signal game_over
signal game_won


# Called when the node enters the scene tree for the first time.
func _ready():
	var fade_tween: Tween = create_tween()
	fade_tween.tween_property($Control/FadeRect, "color", Color(0,0,0,0), 2.0)
	fade_tween.play()
	$WorldEnvironment.environment.background_energy_multiplier = 0.0
	$Surface/DirectionalLight3D.hide()
	$Control2.show()


func _on_ship_died(cause):
	$Control2.hide()
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


func _on_pre_goal_body_entered(body):
	var fade_tween: Tween = create_tween()
	fade_tween.tween_property($Control/FadeRect, "color", Color(1,1,1,0.33), 3.0)
	fade_tween.play()


func _on_goal_body_entered(body):
	$Control2.hide()
	emit_signal("game_won")
	$Ship.dead = true
	var fade_tween: Tween = create_tween()
	fade_tween.tween_property($Control/FadeRect, "color", Color(1,1,1,1.0), 1.0)
	fade_tween.play()
	$CameraChangeTimer.start()


func _on_camera_change_timer_timeout():
	$Surface/Camera3D.make_current()
	var fade_tween: Tween = create_tween()
	fade_tween.tween_property($Control/FadeRect, "color", Color(1,1,1,0.0), 3.0)
	fade_tween.tween_property($Control/CenterContainerEnd, "modulate", Color(1,1,1,1), 2.0)
	fade_tween.play()
	$Control/CenterContainerEnd.show()

	$WorldEnvironment.environment.background_energy_multiplier = 1.0
	$Surface/DirectionalLight3D.show()
	$Ship.vel = Vector3.ZERO
	$Ship.target_vel = Vector3.ZERO


func _on_end_game_timer_timeout():
	emit_signal("game_over")
