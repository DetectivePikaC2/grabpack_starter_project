extends Node3D

@export var jump_boost = 4

func _on_det_area_entered(area):
	print("POWER")
	if Worker.grappling_use == true:
		Worker.handle_pos = $grab_point.global_position
		Worker.handle_rot = $grab_point.rotation + rotation
		Worker.jump_pad_height = jump_boost
		if Worker.current_hand == 1:
			get_tree().call_group("Player", "jump_grabbed")
		else:
			get_tree().call_group("Player", "jump_no")
