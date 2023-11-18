extends Node

@export var end_screen_scene: PackedScene
@export var arena_time_limit: float = 60

@onready var timer = $Timer


func _ready():
	timer.wait_time = arena_time_limit
	timer.start()
	timer.timeout.connect(on_timer_timeout)


func get_time_elapsed():
	return timer.wait_time - timer.time_left


func on_timer_timeout():
	var end_screen_instance = end_screen_scene.instantiate()
	add_child(end_screen_instance)
