extends CharacterBody3D
var vel: Vector3 = Vector3(0,0,-1)
var bounds: Rect2 = Rect2(
	Vector2.ZERO, Vector2(0.3, 0.6)
)
@export_range(0.001, 0.02) var mouse_sensitivity: float = 0.01
var player_vel: Vector3 = Vector3.ZERO
var target_vel: Vector3 = Vector3.ZERO
var target_rot: float = 0.0
var control_states: Dictionary = {
	"steering": 0,
	"speed": 0,
	"lift": 0,
	"pump": 0
}
const PLAYER_SPEED: float = 0.25

var highlighted_node: Node = null

@onready var neck := $Player/Neck
@onready var camera := $Player/Neck/Camera3D
@onready var rc := $Player/Neck/Camera3D/RayCast3D

signal died(cause)

var lever_range: float = 0.08
var max_speed: float = 2.5

var water_start_y: float = -0.5
var water_end_y: float = 0.0
var water_fill_rate: float = 0.015
var water_level: float = 0.0
var water_critical_level: float = 0.65
var water_death_level: float = 0.8
var health: float = 1.0
var flooding: bool = false
var spotted: bool = false
var dead: bool = false
var main_tip_shown: bool = false


var spotted_z: float = -163.0
var breach_z: float = spotted_z - 32.0

var back_light_green: Color = Color("00a730")
var back_light_red: Color = Color("ff2c21")


# Called when the node enters the scene tree for the first time.
func _ready():
	$Controls/Speed/Lever.transform.origin.z = (lever_range / 2) - lever_range * (abs(vel.z) / max_speed)


func handle_controls(node: Node, action: bool) -> void:
	if node.is_in_group("speed"):
		node.tip_shown = true
		if action:
			control_states["speed"] = 1
		else:
			control_states["speed"] = -1
	elif node.is_in_group("steering"):
		node.tip_shown = true
		if action:
			control_states["steering"] = 1
		else:
			control_states["steering"] = -1
	elif node.is_in_group("lift"):
		node.tip_shown = true
		if action:
			control_states["lift"] = -1
		else:
			control_states["lift"] = 1
	elif node.is_in_group("pump"):
		node.tip_shown = true
		if action:
			control_states["pump"] = -1
		else:
			control_states["pump"] = 1
	else:
		print("Unhandled control!")


func _input(event):
	if event.is_action_pressed("debug_forward"):
		$AnimationPlayer.play("Breach")

	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and not dead:
		if event is InputEventMouseMotion:
			neck.rotate_y(-event.relative.x * mouse_sensitivity)
			camera.rotate_x(-event.relative.y * mouse_sensitivity)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-45), deg_to_rad(60))
			if rc.is_colliding():
				if rc.get_collider().is_in_group("controls"):
					if highlighted_node != null:
						highlighted_node.highlight(false)
					highlighted_node = rc.get_collider()
					highlighted_node.highlight(true)
			else:
				if highlighted_node != null:
					highlighted_node.highlight(false)
					highlighted_node = null

		if event is InputEventMouseButton:
			if rc.is_colliding() and event.pressed:
				if rc.get_collider().is_in_group("controls"):
					handle_controls(rc.get_collider(), event.button_index == MOUSE_BUTTON_LEFT)
			elif not event.pressed:
				control_states["steering"] = 0
				control_states["lift"] = 0
				control_states["speed"] = 0
				control_states["pump"] = 0


func _physics_process(delta) -> void:
	if dead:
		return
	_check_raycasts()
	var input_dir := Input.get_vector(
		"move_left", "move_right", "move_forward", "move_backward"
	)
	var move_dir = (
		neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y).normalized()
	)
	
	if control_states["steering"] != 0:
		target_rot += (PI / 8) * delta * control_states["steering"]
	if control_states["lift"] != 0:
		target_vel.y = clamp(
			target_vel.y + 0.75 * control_states["lift"] * delta,
			-1.0, 1.0
		)
	if control_states["speed"] != 0:
		target_vel.z = -clamp(-target_vel.z + 0.5 * control_states["speed"] * delta, 0.0, max_speed)
		if target_vel.z < -max_speed / 3.0 and not main_tip_shown:
			print("MAXMAXMAX")
			$Controls/TipLabel.hide()
			main_tip_shown = true
	if control_states["pump"] != 0:
		water_level = max(water_level - water_fill_rate * 3.0 * delta, 0.0)
	
	if move_dir:
		player_vel.x = move_dir.x * PLAYER_SPEED
		player_vel.z = move_dir.z * PLAYER_SPEED
	else:
		player_vel.x = move_toward(player_vel.x, 0, PLAYER_SPEED)
		player_vel.z = move_toward(player_vel.z, 0, PLAYER_SPEED)

	$Player.transform.origin += player_vel * delta
	$Player.transform.origin.x = clampf(
		$Player.transform.origin.x, -bounds.size.x / 2.0, bounds.size.x / 2
	)
	$Player.transform.origin.z = clampf(
		$Player.transform.origin.z, -bounds.size.y / 2.0, 0.05
	)
	
	self.rotation.y = lerp_angle(self.rotation.y, target_rot, delta * 0.5)
	
	vel = lerp(vel, self.target_vel, delta * 4)
	var v = self.basis * vel
	self.velocity = v
	move_and_slide()
	var col = get_last_slide_collision()
	if col != null and not dead:
		var cv = col.get_travel()
		var force = (cv.length() * 100.0) / max_speed
		health = max(health - force, 0.0)
		if health == 0.0:
			emit_signal("died", "crash")
		else:
			$Bump.play()
		crash(min(force, 1.0))


func _update_control_sounds():
	if control_states["steering"] != 0 and not $Controls/Steering/AudioStreamPlayer3D.playing:
		$Controls/Steering/AudioStreamPlayer3D.play()
	elif control_states["steering"] == 0:
		$Controls/Steering/AudioStreamPlayer3D.stop()
	if control_states["lift"] != 0 and not $Controls/Lift/AudioStreamPlayer3D.playing:
		$Controls/Lift/AudioStreamPlayer3D.play()
	elif control_states["lift"] == 0:
		$Controls/Lift/AudioStreamPlayer3D.stop()
	if control_states["speed"] != 0 and not $Controls/Speed/AudioStreamPlayer3D.playing:
		$Controls/Speed/AudioStreamPlayer3D.play()
	elif control_states["speed"] == 0:
		$Controls/Speed/AudioStreamPlayer3D.stop()

	$LiftScreech.volume_db = linear_to_db(abs(vel.y) * abs(vel.y)) - 4
	$EngineHum.pitch_scale = 0.7 + 0.4 * (abs(vel.z) / max_speed)
	if flooding:
		$Flooding.volume_db = linear_to_db(0.5 + 0.5 * water_level)


func _update_control_meshes(_delta):
	$Controls/Steering/Wheel.rotation.y = rotation.y * 16
	$Controls/Lift/Handle.rotation.x = (PI / 4) * vel.y
	$Controls/Speed/Lever.transform.origin.z = (lever_range / 2) - lever_range * (abs(vel.z) / max_speed)
	if control_states["pump"] != 0 and not $Controls/Pump/AnimationPlayer.is_playing():
		$Controls/Pump/AnimationPlayer.play("pump")
	elif control_states["pump"] == 0 and $Controls/Pump/AnimationPlayer.is_playing():
		$Controls/Pump/AnimationPlayer.play("RESET")


func _check_raycasts():
	if $Raycasts/Front.is_colliding() or flooding:
		$Lights/LeftFront.turn_on()
		$Lights/RightFront.turn_on()
		$Lights/TopFront.turn_on()
		if not $Alarm.playing:
			$Alarm.play()
	else:
		$Alarm.stop()
		if $Raycasts/Left1.is_colliding() or $Raycasts/Left2.is_colliding() or $Raycasts/Left3.is_colliding():
			$Lights/LeftFront.turn_on()
		else:
			$Lights/LeftFront.turn_off()
		if $Raycasts/Right1.is_colliding() or $Raycasts/Right2.is_colliding() or $Raycasts/Right3.is_colliding():
			$Lights/RightFront.turn_on()
		else:
			$Lights/RightFront.turn_off()
		if $Raycasts/Front2.is_colliding() or $Raycasts/Front3.is_colliding():
			$Lights/TopFront.turn_on()
		else:
			$Lights/TopFront.turn_off()


func crash(force: float) -> void:
	camera.add_trauma(force * 2.0)


func breach() -> void:
	print("BREACH")
	$Alarm.play()
	$Flooding.play()
	$Flooding.volume_db = linear_to_db(0.5 + 0.5 * water_level)
	$Lights/Back.light_color = back_light_red
	flooding = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_update_control_meshes(delta)
	_update_control_sounds()
	if not spotted and transform.origin.z < spotted_z:
		spotted = true
		$AnimationPlayer.play("Spotted")
	if not flooding and transform.origin.z < breach_z:
		$AnimationPlayer.play("Breach")
	
	if flooding:
		water_level += water_fill_rate * delta
		$Body/Water.transform.origin.y = lerpf(water_start_y, water_end_y, water_level)
		if water_level >= water_critical_level:
			var bus_id = AudioServer.get_bus_index("Effects")
			AudioServer.set_bus_effect_enabled(bus_id, 0, true)
		else:
			var bus_id = AudioServer.get_bus_index("Effects")
			AudioServer.set_bus_effect_enabled(bus_id, 0, false)


func _on_died(cause):
	if cause == "crash":
		print("Died in a crash")
	elif cause == "drowning":
		print("Died by drowning")
	dead = true
	$Crash.play()
