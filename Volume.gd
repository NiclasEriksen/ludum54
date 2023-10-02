extends Node
var fade_tween: Tween = null
var custom_level: float = 0.0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func set_custom_volume(level: float):
	custom_level = level
	set_volume(level)


func set_volume(level: float, fade: bool = false) -> void:
	if fade:
		if fade_tween != null:
			fade_tween.stop()
		fade_tween = create_tween()
		if level < AudioServer.get_bus_volume_db(0):
			fade_tween.set_ease(Tween.EASE_IN)
		else:
			fade_tween.set_ease(Tween.EASE_OUT)
		fade_tween.set_trans(Tween.TRANS_CUBIC)
		fade_tween.tween_method(
			_set_volume, AudioServer.get_bus_volume_db(0), level, 2.5
		)
		fade_tween.play()
	else:
		_set_volume(level)


func _set_volume(db: float) -> void:
	AudioServer.set_bus_volume_db(0, db)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
