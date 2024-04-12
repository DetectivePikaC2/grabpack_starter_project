class_name Player extends CharacterBody3D

@export_category("Player")
@export_range(1, 35, 1) var speed: float = 10 # m/s
@export_range(10, 400, 1) var acceleration: float = 100 # m/s^2

@export_range(0.1, 3.0, 0.1) var jump_height: float = 1 # m
@export_range(0.1, 3.0, 0.1, "or_greater") var camera_sens: float = 1

var jumping: bool = false
var mouse_captured: bool = false

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var move_dir: Vector2 # Input direction for movement
var look_dir: Vector2 # Input direction for look/aim

var walk_vel: Vector3 # Walking velocity 
var grav_vel: Vector3 # Gravity velocity 
var jump_vel: Vector3 # Jumping velocity

@onready var camera: Camera3D = $layer1/layer2/layer3/layer4/layer5/Camera
@onready var rotatable = $layer1

var grappling = false
var hookpoint = Vector3()
var hookpoint_get = false
var look_at_cords = Vector3()

var grappling_left = false
var hookpoint_left = Vector3()
var hookpoint_get_left = false
var grapple_left_shoot = false
var rocket_jump = false
var jumped = false
var crouching = false
var left_pos = Vector3()
var left_land = false
var grabpack_disabled = false
var grabbing_pack = false

@export var start_with_grabpack = true
@export var run_speed = 4.0
@export var original_speed = 4.0
@export var crouch_speed = 2.0
@export var use_other_hand_sway = false
@export var flashlight = false
@export var FOV = 80

var flare = preload("res://Player_Worker/flare.tscn")

@onready var line = $layer1/Grab_layer1/line
@onready var grapplecast = $layer1/Grab_layer1/hand_cast
@onready var batterycast = $layer1/Grab_layer1/battery_cast
@onready var flash_light = $layer1/Grab_layer1/Grab_layer2/Grab_layer3/RootNode/right_hands/SpotLight3D

func _ready() -> void:
	Worker.has_grabpack = start_with_grabpack
	if not start_with_grabpack:
		grabpack_disabled = true
	Worker.adaptive_sway = use_other_hand_sway
	$layer1/layer2/layer3/layer4/layer5/Camera.fov = FOV
	capture_mouse()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		look_dir = event.relative * 0.001
		if mouse_captured: _rotate_camera()
	if Input.is_action_just_pressed("jump"): jumping = true
	if Input.is_action_just_pressed("exit"): get_tree().quit()
	if Input.is_action_just_pressed("1") and not Worker.has_grabpack:
		print("worked")
		collect_grabpack()

func left_hand_use():
	if Input.is_action_just_released("left_hand"):
		if grapplecast.is_colliding():
			if Worker.battery_left:
				left_battery_release()
			elif not grappling_left:
				grappling_left = true
				$layer1/Grab_layer1/audio/grab_left.play()
				$layer1/Grab_layer1/line2.visible = true
				$layer1/Grab_layer1/Grab_layer2/Grab_layer3/RootNode/left_hands/Hand_Blue.reparent($hand_holder)
			else:
				grappling_left = false
				hookpoint_get_left = false
				Worker.handle_available_left = false
				Worker.left_grappling_use = grappling_left
				$layer1/Grab_layer1/audio/grab_left2.play()
				$layer1/Grab_layer1/line2.visible = false
				$hand_holder/Hand_Blue.reparent($layer1/Grab_layer1/Grab_layer2/Grab_layer3/RootNode/left_hands)
				$layer1/Grab_layer1/Grab_layer2/Grab_layer3/RootNode/left_hands/Hand_Blue.transform.origin = $layer1/Grab_layer1/Grab_layer2/Grab_layer3/RootNode/left_hands/blue_og_pos.transform.origin
				$layer1/Grab_layer1/Grab_layer2/Grab_layer3/RootNode/left_hands/Hand_Blue.rotation = $layer1/Grab_layer1/Grab_layer2/Grab_layer3/RootNode/left_hands/blue_og_pos.rotation
				$layer1/Grab_layer1/Grab_layer2/Grab_layer3/RootNode/left_hands/Hand_Blue/blue_player.play("retract_hit")
				$layer1/Grab_layer1/Grab_layer2/Grab_layer3/RootNode/lphysics.play("retract_left")
				Worker.handle_available = false
	if grappling_left:
		if not hookpoint_get_left:
			hookpoint_left = grapplecast.get_collision_point()
			hookpoint_get_left = true
		look_at_cords
		$layer1/Grab_layer1/line2.look_at($hand_holder/Hand_Blue/line_marker.global_position)
		$layer1/Grab_layer1/line2.scale.z = hookpoint_left.distance_to($layer1/Grab_layer1/line2.global_position) / 60
		$hand_holder/Hand_Blue.transform.origin = hookpoint_left - transform.origin
	Worker.left_grappling_use = grappling_left

func hand_right_use():
	if Input.is_action_just_released("right_hand") and not Worker.switching:
		if grapplecast.is_colliding():
			if Worker.battery_right == true:
				right_battery_release()
			elif not grappling:
				grappling = true
				$layer1/Grab_layer1/audio/grab_right.play()
				$layer1/Grab_layer1/line.visible = true
				$layer1/Grab_layer1/Grab_layer2/Grab_layer3/RootNode/right_hands/Hand_Green.reparent($hand_holder)
			else:
				hand_release_right()
	if grappling:
		if not hookpoint_get:
			hookpoint = grapplecast.get_collision_point()
			hookpoint_get = true
		look_at_cords
		$layer1/Grab_layer1/line.look_at($hand_holder/Hand_Green/line_marker.global_position)
		$layer1/Grab_layer1/line.scale.z = hookpoint.distance_to($layer1/Grab_layer1/line.global_position) / 60
		$hand_holder/Hand_Green.transform.origin = hookpoint - transform.origin
	Worker.grappling_use = grappling
func hand_rocket_use():
	if Input.is_action_just_released("right_hand") and not Worker.switching:
		if grapplecast.is_colliding():
			if Worker.battery_right == true:
				right_battery_release()
			elif not grappling:
				$layer1/Grab_layer1/audio/grab_right.play()
				grappling = true
				$layer1/Grab_layer1/line.visible = true
				$layer1/Grab_layer1/Grab_layer2/Grab_layer3/RootNode/right_hands/Hand_Rocket.reparent($hand_holder)
			else:
				hand_release_right()
	if grappling:
		if not hookpoint_get:
			hookpoint = grapplecast.get_collision_point()
			hookpoint_get = true
		look_at_cords
		$layer1/Grab_layer1/line.look_at($hand_holder/Hand_Rocket/line_marker.global_position)
		$layer1/Grab_layer1/line.scale.z = hookpoint.distance_to($layer1/Grab_layer1/line.global_position) / 60
		$hand_holder/Hand_Rocket.transform.origin = hookpoint - transform.origin
	Worker.grappling_use = grappling
func hand_flare_use():
	if Input.is_action_just_pressed("right_hand") and not Worker.switching:
		$layer1/Grab_layer1/Grab_layer2/Grab_layer3/RootNode/rphysics.play("retract_left_hit")
		$layer1/Grab_layer1/Grab_layer2/Grab_layer3/RootNode/right_hands/fire.play("flare")
		Worker.flare_rot = $layer1.rotation
		get_tree().call_group("ball_hand", "hand_spawn")

func _process(delta):
	Worker.player_pos = global_position
	if not grabpack_disabled:
		handle_walk_physics()
		$layer1/Grab_layer1.visible = true
		if jumped and is_on_floor():
			$layer1/jump.play("land")
			jumped = false
		if Worker.handle_available == true and Input.is_action_pressed("right_hand"):
			Worker.grappling = true
			if hookpoint.distance_to(transform.origin) > 2:
				if hookpoint_get:
					transform.origin = lerp(transform.origin, hookpoint, 0.01)
		else:
			Worker.grappling = false
		if Worker.handle_available_left and Input.is_action_pressed("left_hand"):
			if hookpoint_left.distance_to(transform.origin) > 2:
				if hookpoint_get_left:
					transform.origin = lerp(transform.origin, hookpoint_left, 0.01)
		else:
			Worker.left_grappling_use = false
		if Worker.current_hand == 0:
			hand_right_use()
		elif Worker.current_hand == 1:
			hand_rocket_use()
		elif Worker.current_hand == 2:
			hand_flare_use()
		left_hand_use()
	else:
		if not grabbing_pack:
			handle_walk_physics_no_grabpack()
			$layer1/Grab_layer1.visible = false
	if flashlight:
		flash_light.visible = true
	else:
		flash_light.visible = false

func _physics_process(delta: float) -> void:
	if Worker.allow_movement:
		if mouse_captured: _handle_joypad_camera_rotation(delta)
		if Worker.handle_available == false and Worker.handle_available_left == false:
			velocity = _walk(delta) + _gravity(delta) + _jump(delta)
			if rocket_jump:
				jump_height = 1
				rocket_jump = false
		else:
			velocity = _walk(delta)
		move_and_slide()

func capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func release_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false

func _rotate_camera(sens_mod: float = 1.0) -> void:
	if Worker.allow_movement:
		rotatable.rotation.y -= look_dir.x * camera_sens * sens_mod
		rotatable.rotation.x = clamp(rotatable.rotation.x - look_dir.y * camera_sens * sens_mod, -1.5, 1.5)

func _handle_joypad_camera_rotation(delta: float, sens_mod: float = 1.0) -> void:
	var joypad_dir: Vector2 = Input.get_vector("look_left","look_right","look_up","look_down")
	if joypad_dir.length() > 0:
		look_dir += joypad_dir * delta
		_rotate_camera(sens_mod)
		look_dir = Vector2.ZERO

func _walk(delta: float) -> Vector3:
	move_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backwards")
	var _forward: Vector3 = camera.global_transform.basis * Vector3(move_dir.x, 0, move_dir.y)
	var walk_dir: Vector3 = Vector3(_forward.x, 0, _forward.z).normalized()
	walk_vel = walk_vel.move_toward(walk_dir * speed * move_dir.length(), acceleration * delta)
	return walk_vel

func _gravity(delta: float) -> Vector3:
	grav_vel = Vector3.ZERO if is_on_floor() else grav_vel.move_toward(Vector3(0, velocity.y - gravity, 0), gravity * delta)
	return grav_vel

func _jump(delta: float) -> Vector3:
	if jumping:
		$layer1/jump.play("jump")
		jumped = true
		if is_on_floor(): jump_vel = Vector3(0, sqrt(4 * jump_height * gravity), 0)
		jumping = false
		return jump_vel
	jump_vel = Vector3.ZERO if is_on_floor() else jump_vel.move_toward(Vector3.ZERO, gravity * delta)
	return jump_vel

func green_scale_map():
	$layer1/Grab_layer1/Grab_layer2/Grab_layer3/RootNode/right_hands/Hand_Green.scale.x = -0.6
	$layer1/Grab_layer1/Grab_layer2/Grab_layer3/RootNode/right_hands/Hand_Green.scale.y = -0.6
	$layer1/Grab_layer1/Grab_layer2/Grab_layer3/RootNode/right_hands/Hand_Green.scale.z = -0.6
func green_scale_reset():
	$layer1/Grab_layer1/Grab_layer2/Grab_layer3/RootNode/right_hands/Hand_Green.scale.x = -10
	$layer1/Grab_layer1/Grab_layer2/Grab_layer3/RootNode/right_hands/Hand_Green.scale.y = -10
	$layer1/Grab_layer1/Grab_layer2/Grab_layer3/RootNode/right_hands/Hand_Green.scale.z = -10

func handle_grabbed():
	if grappling:
		hookpoint = Worker.handle_pos
		Worker.handle_available = true
		if Worker.current_hand == 0:
			$hand_holder/Hand_Green.rotation = Worker.handle_rot
		elif Worker.current_hand == 1:
			$hand_holder/Hand_Rocket.rotation = Worker.handle_rot
func handle_grabbed_left():
	if grappling_left:
		hookpoint_left = Worker.handle_pos_left
		Worker.handle_available_left = true
		$hand_holder/Hand_Blue.rotation = Worker.handle_rot_left
func power_grabbed():
	if Worker.grappling_use:
		hookpoint = Worker.handle_pos
		Worker.power_available = true
		if Worker.current_hand == 0:
			$hand_holder/Hand_Green.rotation = Worker.handle_rot
		elif Worker.current_hand == 1:
			$hand_holder/Hand_Rocket.rotation = Worker.handle_rot
func power_no():
	if Worker.grappling_use:
		hookpoint = Worker.handle_pos
		if Worker.current_hand == 0:
			$hand_holder/Hand_Green.rotation = Worker.handle_rot
		elif Worker.current_hand == 1:
			$hand_holder/Hand_Rocket.rotation = Worker.handle_rot


func hand_left_release():
	grappling_left = false
	hookpoint_get_left = false
	$layer1/Grab_layer1/line2.visible = false
	$hand_holder/Hand_Blue.reparent($layer1/Grab_layer1/Grab_layer2/Grab_layer3/RootNode/left_hands)
	$layer1/Grab_layer1/Grab_layer2/Grab_layer3/RootNode/left_hands/Hand_Blue.transform.origin = $layer1/Grab_layer1/Grab_layer2/Grab_layer3/RootNode/left_hands/blue_og_pos.transform.origin
	$layer1/Grab_layer1/Grab_layer2/Grab_layer3/RootNode/left_hands/Hand_Blue.rotation = $layer1/Grab_layer1/Grab_layer2/Grab_layer3/RootNode/left_hands/blue_og_pos.rotation
	$layer1/Grab_layer1/Grab_layer2/Grab_layer3/RootNode/left_hands/Hand_Blue/blue_player.play("retract_hit")
	$layer1/Grab_layer1/Grab_layer2/Grab_layer3/RootNode/lphysics.play("retract_left")
	Worker.handle_available = false

func hand_release_right():
	grappling = false
	hookpoint_get = false
	Worker.grappling_use = false
	Worker.handle_available = false
	$layer1/Grab_layer1/line.visible = false
	$layer1/Grab_layer1/audio/grab_right2.play()
	if Worker.current_hand == 0:
		$hand_holder/Hand_Green.reparent($layer1/Grab_layer1/Grab_layer2/Grab_layer3/RootNode/right_hands)
		$layer1/Grab_layer1/Grab_layer2/Grab_layer3/RootNode/right_hands/Hand_Green.transform.origin = $layer1/Grab_layer1/Grab_layer2/Grab_layer3/RootNode/right_hands/green_og_pos.transform.origin
		$layer1/Grab_layer1/Grab_layer2/Grab_layer3/RootNode/right_hands/Hand_Green.rotation = $layer1/Grab_layer1/Grab_layer2/Grab_layer3/RootNode/right_hands/green_og_pos.rotation
		$layer1/Grab_layer1/Grab_layer2/Grab_layer3/RootNode/right_hands/Hand_Green/green_player.play("retract_hit")
	elif Worker.current_hand == 1:
		$hand_holder/Hand_Rocket.reparent($layer1/Grab_layer1/Grab_layer2/Grab_layer3/RootNode/right_hands)
		$layer1/Grab_layer1/Grab_layer2/Grab_layer3/RootNode/right_hands/Hand_Rocket.transform.origin = $layer1/Grab_layer1/Grab_layer2/Grab_layer3/RootNode/right_hands/rocket_og_pos.transform.origin
		$layer1/Grab_layer1/Grab_layer2/Grab_layer3/RootNode/right_hands/Hand_Rocket.rotation = $layer1/Grab_layer1/Grab_layer2/Grab_layer3/RootNode/right_hands/rocket_og_pos.rotation
	$layer1/Grab_layer1/Grab_layer2/Grab_layer3/RootNode/rphysics.play("retract_left_hit")
	if Worker.power_available == true:
		get_tree().call_group("power_source", "power_grabbed_success")
		Worker.hand_powered = true
		Worker.power_available = false
		$layer1/Grab_layer1/Grab_layer2/Grab_layer3/RootNode/right_hands/Hand_Green/green_light.visible = true
		
	grapple_left_shoot = false
func power_returned():
	if grappling == false or not Worker.current_hand == 0:
		$layer1/Grab_layer1/Grab_layer2/Grab_layer3/RootNode/right_hands/Hand_Green/green_light.visible = false
	else:
		$hand_holder/Hand_Green/green_light.visible = false

func power_rev_grabbed():
	if Worker.grappling_use:
		hookpoint = Worker.handle_pos
		if Worker.current_hand == 0:
			$hand_holder/Hand_Green.rotation = Worker.handle_rot
		elif Worker.current_hand == 1:
			$hand_holder/Hand_Rocket.rotation = Worker.handle_rot
		if Worker.hand_powered == true:
			print("wat")
			Worker.hand_powered = false
			if Worker.grappling_use == true:
				$hand_holder/Hand_Green/green_light.visible = false
			else:
				$layer1/Grab_layer1/Grab_layer2/Grab_layer3/RootNode/right_hands/Hand_Green/green_light.visible = false
func power_rev_no():
	if Worker.grappling_use:
		hookpoint = Worker.handle_pos
		if Worker.current_hand == 0:
			$hand_holder/Hand_Green.rotation = Worker.handle_rot
		elif Worker.current_hand == 1:
			$hand_holder/Hand_Rocket.rotation = Worker.handle_rot

func jump_grabbed():
	if Worker.grappling_use:
		hookpoint = Worker.handle_pos
		if Worker.current_hand == 0:
			$hand_holder/Hand_Green.rotation = Worker.handle_rot
		elif Worker.current_hand == 1:
			$hand_holder/Hand_Rocket.rotation = Worker.handle_rot
			jump_height = Worker.jump_pad_height
			rocket_jump = true
			jumping = true
func jump_no():
	if Worker.grappling_use:
		hookpoint = Worker.handle_pos
		if Worker.current_hand == 0:
			$hand_holder/Hand_Green.rotation = Worker.handle_rot
		elif Worker.current_hand == 1:
			$hand_holder/Hand_Rocket.rotation = Worker.handle_rot

func handle_walk_physics():
	$layer1/Grab_layer1/line.global_position = $layer1/Grab_layer1/Grab_layer2/Grab_layer3/line1_pos.global_position
	$layer1/Grab_layer1/line2.global_position = $layer1/Grab_layer1/Grab_layer2/Grab_layer3/line2_pos.global_position
	if not jumped:
		if Input.is_action_pressed("move_forward") or Input.is_action_pressed("move_backwards") or Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left"):
			if Input.is_action_pressed("run"):
				$layer1/walk.play("run")
			else:
				$layer1/walk.play("walk")
		else:
			$layer1/walk.play("idle")
		if Input.is_action_pressed("move_forward"):
			$layer1/lr_physics.play("forwards")
		elif Input.is_action_pressed("move_backwards"):
			$layer1/lr_physics.play("backwards")
		elif Input.is_action_pressed("move_left") and Input.is_action_pressed("move_right"):
			$layer1/lr_physics.play("RESET")
		elif Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
			if Input.is_action_pressed("move_left"):
				$layer1/lr_physics.play("left")
			if Input.is_action_pressed("move_right"):
				$layer1/lr_physics.play("right")
		else:
			$layer1/lr_physics.play("RESET")
		if Input.is_action_pressed("run") and not crouching:
			speed = run_speed
		else:
			if Input.is_action_pressed("crouch"):
				if not crouching:
					$crouch_player.play("crouch")
					crouching = true
				speed = crouch_speed
			else:
				if crouching:
					$crouch_player.play("uncrouch")
					crouching = false
				speed = original_speed
func reset_hand_pos():
	$layer1/Grab_layer1/Grab_layer2/Grab_layer3/RootNode/right_hands/Hand_Green.transform.origin = $layer1/Grab_layer1/Grab_layer2/Grab_layer3/RootNode/right_hands/green_og_pos.transform.origin
	$layer1/Grab_layer1/Grab_layer2/Grab_layer3/RootNode/right_hands/Hand_Green.rotation = $layer1/Grab_layer1/Grab_layer2/Grab_layer3/RootNode/right_hands/green_og_pos.rotation
	$layer1/Grab_layer1/Grab_layer2/Grab_layer3/RootNode/right_hands/Hand_Rocket.transform.origin = $layer1/Grab_layer1/Grab_layer2/Grab_layer3/RootNode/right_hands/rocket_og_pos.transform.origin
	$layer1/Grab_layer1/Grab_layer2/Grab_layer3/RootNode/right_hands/Hand_Rocket.rotation = $layer1/Grab_layer1/Grab_layer2/Grab_layer3/RootNode/right_hands/rocket_og_pos.rotation

func battery_grabbed():
	if Worker.grappling_use:
		hookpoint = Worker.handle_pos
		if Worker.current_hand == 0:
			$hand_holder/Hand_Green.rotation = Worker.handle_rot
		elif Worker.current_hand == 1:
			$hand_holder/Hand_Rocket.rotation = Worker.handle_rot
func battery_grabbed_l():
	if Worker.left_grappling_use:
		hookpoint_left = Worker.handle_pos_left
		$hand_holder/Hand_Blue.rotation = Worker.handle_rot_left
func get_battery_pose():
	Worker.battery_pos = $layer1/Grab_layer1/Grab_layer2/Grab_layer3/RootNode/right_hands/held_obj.global_position
	Worker.battery_rot = $layer1.global_rotation
func get_battery_pose_left():
	Worker.battery_pos_left = $layer1/Grab_layer1/Grab_layer2/Grab_layer3/RootNode/left_hands/held_obj.global_position
	Worker.battery_rot_left = $layer1.global_rotation
func right_battery_release():
	if batterycast.is_colliding():
		print("battery_time :)")
		get_tree().call_group("battery_rev", "battery_placed")
	else:
		Worker.battery_right = false
func left_battery_release():
	if batterycast.is_colliding():
		print("battery_time :)")
		get_tree().call_group("battery_rev", "battery_placed")
	else:
		Worker.battery_left = false
func blue_panel_grabbed():
	if Worker.left_grappling_use:
		hookpoint_left = Worker.handle_pos_left
		$hand_holder/Hand_Blue.rotation = Worker.handle_rot_left

func collect_grabpack():
	grabbing_pack = true
	$layer1/walk.play("collect_grabpack")
	$layer1/Grab_layer1.visible = true

func handle_walk_physics_no_grabpack():
	if not jumped:
		if Input.is_action_pressed("move_forward") or Input.is_action_pressed("move_backwards") or Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left"):
			$layer1/walk.play("walk_no_pack")
		else:
			$layer1/walk.play("idle_no_pack")
		if Input.is_action_pressed("run") and not crouching:
			speed = run_speed
		else:
			if Input.is_action_pressed("crouch"):
				if not crouching:
					$crouch_player.play("crouch")
					crouching = true
				speed = crouch_speed
			else:
				if crouching:
					$crouch_player.play("uncrouch")
					crouching = false
				speed = original_speed

func _on_pack_thing_area_entered(area):
	Worker.has_grabpack = true
	grabbing_pack = false
	grabpack_disabled = false
