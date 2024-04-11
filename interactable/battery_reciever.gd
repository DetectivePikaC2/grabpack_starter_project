extends Node3D

var battery_col = false
@export var battery_rev_number = 0

func battery_placed():
	if battery_col:
		Worker.battery_rev_active = true
		Worker.battery_rev_pos = $battery_point.global_position
		Worker.battery_rev_rot = $battery_point.global_rotation
		Worker.battery_rev_finish = battery_rev_number
		get_tree().call_group("level", "battery_rev_complete")


func _on_battery_collider_2_area_entered(area):
	battery_col = true

func _on_battery_collider_2_area_exited(area):
	battery_col = false
