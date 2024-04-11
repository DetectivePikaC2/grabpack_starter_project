extends Node3D

var new_flare = true
var hookpoint = Vector3()
@onready var cast = $RayCast3D

func _ready():
	transform.origin = Worker.flare_pos
	#rotation = Worker.flare_rot
	print("spawned")

func _process(delta):
	if new_flare == false:
		hookpoint = cast.get_collision_point()
		transform.origin = lerp(transform.origin, hookpoint, 0.01)

func flare_update():
	if new_flare == true:
		new_flare = false

func _on_timer_timeout():
	queue_free()
