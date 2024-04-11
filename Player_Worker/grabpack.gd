extends Node3D

var mouseMovementY
var mouseMovementX
var swayThreshold = 5
var swayLerp = 8

var grappling = false
var hookpoint = Vector3()
var hookpoint_get = false
var switch_dir = 1
var switching = false
var switch_hand = 0

var speed = Vector2()

@onready var grapplecast = $hand_cast

@export var swayLeft : Vector3
@export var swayRight : Vector3
@export var swayUp : Vector3
@export var swayDown : Vector3
@export var swayNormal : Vector3

func _input(event):
	if event is InputEventMouseMotion:
		mouseMovementY = -event.relative.x
		mouseMovementX = event.relative.y
		speed = Input.get_last_mouse_velocity() / 50
	if Worker.has_grabpack and not Worker.switching:
		switch_hand = -1
		if Input.is_action_just_pressed("hand_switch_up") and Worker.grappling_use == false:
			Worker.switching = true
			switch_dir = 1
			$Grab_layer2/Grab_layer3/RootNode/rhand_change.play("hand_switch_rocket")
		if Input.is_action_just_pressed("hand_switch_down") and Worker.grappling_use == false:
			Worker.switching = true
			switch_dir = -1
			$Grab_layer2/Grab_layer3/RootNode/rhand_change.play("hand_switch_rocket")
		if Input.is_action_just_pressed("1"):
			Worker.switching = true
			switch_hand = 0
			$Grab_layer2/Grab_layer3/RootNode/rhand_change.play("hand_switch_rocket")
		if Input.is_action_just_pressed("2"):
			Worker.switching = true
			switch_hand = 1
			$Grab_layer2/Grab_layer3/RootNode/rhand_change.play("hand_switch_rocket")
		if Input.is_action_just_pressed("3"):
			Worker.switching = true
			switch_hand = 2
			$Grab_layer2/Grab_layer3/RootNode/rhand_change.play("hand_switch_rocket")
func _ready():
	hand_reload()

func _process(delta):
	if Worker.adaptive_sway == true:
		get_new_sway()
	Worker.hand_pos = position
	if mouseMovementY != null:
		if mouseMovementY > swayThreshold:
			rotation = rotation.lerp(swayLeft, swayLerp * delta)
		elif mouseMovementY < -swayThreshold:
			rotation = rotation.lerp(swayRight, swayLerp * delta)
		if mouseMovementX > swayThreshold:
			rotation = rotation.lerp(swayUp, swayLerp * delta)
		elif mouseMovementX < -swayThreshold:
			rotation = rotation.lerp(swayDown, swayLerp * delta)
		else:
			rotation = rotation.lerp(swayNormal, swayLerp * delta)

func _on_switch_trigger_2_area_entered(area):
	if not switch_hand > 0:
		if switch_dir > 0:
			Worker.current_hand += 1
			if Worker.current_hand > Worker.hand_amount:
				Worker.current_hand = 0
		else:
			Worker.current_hand -= 1
			if Worker.current_hand < 0:
				Worker.current_hand = Worker.hand_amount
	else:
		Worker.current_hand = switch_hand
	hand_reload()

func hand_reload():
	if Worker.current_hand == 0:
		$Grab_layer2/Grab_layer3/RootNode/right_hands/Hand_Green.visible = true
		$Grab_layer2/Grab_layer3/RootNode/right_hands/Hand_Rocket.visible = false
		$Grab_layer2/Grab_layer3/RootNode/right_hands/Hand_Flare.visible = false
	elif Worker.current_hand == 1:
		$Grab_layer2/Grab_layer3/RootNode/right_hands/Hand_Green.visible = false
		$Grab_layer2/Grab_layer3/RootNode/right_hands/Hand_Rocket.visible = true
		$Grab_layer2/Grab_layer3/RootNode/right_hands/Hand_Flare.visible = false
	elif Worker.current_hand == 2:
		$Grab_layer2/Grab_layer3/RootNode/right_hands/Hand_Green.visible = false
		$Grab_layer2/Grab_layer3/RootNode/right_hands/Hand_Rocket.visible = false
		$Grab_layer2/Grab_layer3/RootNode/right_hands/Hand_Flare.visible = true
	Worker.switching = false

func _on_hit_body_entered(body):
	get_tree().call_group("level", "green_hit")

func green_retracted():
	$Grab_layer2/Grab_layer3/RootNode/right_hands/Hand_Green

func get_new_sway():
	if speed.x < 0:
		swayLeft.y = speed.x / 200
	else:
		swayRight.y = speed.x / 200
	if speed.y < 0:
		swayDown.x = speed.y / 200
	else:
		swayUp.x = speed.y / 200
