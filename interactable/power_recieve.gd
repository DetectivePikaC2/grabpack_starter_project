extends Node3D

var power_status = false
@export var recieve_number = 0

func _on_det_area_entered(area):
	print("POWER WOW")
	if Worker.grappling_use == true:
		#Worker.handle_pos = global_position
		Worker.handle_pos = $grab_point.global_position
		Worker.handle_rot = $grab_point.rotation + rotation
		if Worker.hand_powered == true and Worker.current_hand == 0 and power_status == false:
			get_tree().call_group("Player", "power_rev_grabbed")
			power_rev_success()
		else:
			get_tree().call_group("Player", "power_rev_no")
func power_rev_success():
	power_status = true
	$grab_sfx.play()
	$light.visible = true
	Worker.revieve_done = position
	print(Worker.revieve_done)
	Worker.recieve_finish = recieve_number
	get_tree().call_group("level", "reciever_active")
