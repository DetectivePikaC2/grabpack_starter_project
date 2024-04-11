extends Node3D

func _input(event):
	if Input.is_action_just_pressed("interact") and Worker.selected == 1:
		get_tree().call_group("Player", "collect_grabpack")
		$AudioStreamPlayer.play()
		Worker.selected = 0
		position.y -= 5000

func _on_item_col_area_entered(area):
	Worker.selected = 1

func _on_item_col_area_exited(area):
	Worker.selected = 0

func _on_audio_stream_player_finished():
	queue_free()
