extends Node3D

var grabbed = false

func _on_det_area_entered(area):
	if Worker.grappling_use and Worker.handle_available == false:
		Worker.handle_pos = $grab_point.global_position
		Worker.handle_rot = $grab_point.rotation
		grabbed = true
		get_tree().call_group("Player", "handle_grabbed")

func _on_det_left_area_entered(area):
	if Worker.left_grappling_use and Worker.handle_available_left == false:
		Worker.handle_pos_left = $grab_point.global_position
		Worker.handle_rot_left = $grab_point_l.rotation
		grabbed = true
		get_tree().call_group("Player", "handle_grabbed_left")
