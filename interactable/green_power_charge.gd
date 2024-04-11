extends Node3D

var power_status = true

func _on_det_area_entered(area):
	print("POWER")
	if Worker.grappling_use == true:
		Worker.handle_pos = $grab_point.global_position
		Worker.handle_rot = $grab_point.rotation + rotation
		if Worker.current_hand == 0 and power_status == true:
			get_tree().call_group("Player", "power_grabbed")
		else:
			get_tree().call_group("Player", "power_no")

func power_grabbed_success():
	power_status = false
	$grab_sfx.play()
	$light.visible = false
	$Timer.start()

func _on_timer_timeout():
	power_status = true
	$grab_sfx2.play()
	$light.visible = true
	Worker.hand_powered = false
	get_tree().call_group("Player", "power_returned")
