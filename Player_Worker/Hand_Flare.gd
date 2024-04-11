extends Node3D

var flare = preload("res://Player_Worker/flare.tscn")

func hand_spawn():
	var instance = flare.instantiate()
	Worker.flare_pos = $flare_spawn.position
	instance.set_name("flare")
	add_child(instance)
	get_tree().call_group("level", "flare_spawned")
