extends Node3D

var disabled = false
@export var scanner_number = 0
@export var panel_disabled = false

func _ready():
	$scanner_anim.play("blank")

func _on_auto_1_area_entered(area):
	Worker.blue_scanner_number = scanner_number
	get_tree().call_group("level", "blue_panel_finish")
	disabled = true

func _on_det_area_exited(area):
	if not disabled:
		$scanner_anim.play("blank")
		$scanlines/scan_sfx.stop()

func _on_det_area_entered(area):
	if Worker.left_grappling_use and not disabled and not panel_disabled:
		Worker.handle_pos_left = $grab_point.global_position
		Worker.handle_rot_left = $grab_point.global_rotation
		get_tree().call_group("Player", "blue_panel_grabbed")
		$scanlines/scan_sfx.play()
		$scanner_anim.play("scan_backwards")
	elif Worker.left_grappling_use and disabled or panel_disabled:
		Worker.handle_pos_left = $grab_point.global_position
		Worker.handle_rot_left = $grab_point.global_rotation
		get_tree().call_group("Player", "blue_panel_grabbed")
