extends RigidBody3D

var grabbed = false
var grabbed_l = false
var holding = false
var holding_l = false
var falling = 0
var placed = false
var placed_pos = Vector3()
var placed_rot = Vector3()
var battery_place = 0

func _on_det_area_entered(area):
	print("woah")
	if Worker.grappling_use == true and placed == false:
		Worker.handle_pos = $grab_point.global_position
		Worker.handle_rot = $grab_point.rotation
		grabbed = true
		get_tree().call_group("Player", "battery_grabbed")

func _on_det_left_area_entered(area):
	print("woah")
	if Worker.left_grappling_use == true and placed == false:
		Worker.handle_pos_left = $grab_point_left.global_position
		Worker.handle_rot_left = $grab_point_left.rotation
		grabbed_l = true
		get_tree().call_group("Player", "battery_grabbed_l")

func _process(delta):
	if grabbed and not Worker.grappling_use:
		Worker.battery_right = true
		holding = true
		grabbed = false
		battery_place = 0
	if grabbed_l and not Worker.left_grappling_use:
		Worker.battery_left = true
		holding_l = true
		grabbed_l = false
		battery_place = 1
	if holding:
		get_tree().call_group("Player", "get_battery_pose")
		if Worker.grappling_use or Worker.battery_right == false:
			holding = false
			falling += 1
		global_position = Worker.battery_pos
		rotation = Worker.battery_rot
	if holding_l:
		get_tree().call_group("Player", "get_battery_pose_left")
		if Worker.left_grappling_use or Worker.battery_left == false:
			holding_l = false
			falling += 1
		global_position = Worker.battery_pos_left
		rotation = Worker.battery_rot_left
	if Worker.battery_rev_active and holding:
		print('PLACED')
		placed = true
		placed_pos = Worker.battery_rev_pos
		placed_rot = Worker.battery_rev_rot
		holding = false
		Worker.battery_right = false
		Worker.battery_rev_active = false
	if Worker.battery_rev_active and holding_l:
		print('PLACED')
		placed = true
		placed_pos = Worker.battery_rev_pos
		placed_rot = Worker.battery_rev_rot
		holding_l = false
		Worker.battery_left = false
		Worker.battery_rev_active = false
	if placed:
		if placed_pos.distance_to(transform.origin) > 1:
			transform.origin = lerp(transform.origin, placed_pos, 0.5)
		else:
			global_position = placed_pos
			global_rotation = placed_rot
	if falling > 0:
		falling -= 0.5
