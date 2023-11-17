extends Node

# Half of viewport width with a little bit extra to avoid the enemies being seen spawning at the edges of the screen
const SPAWN_RADIUS = 375

@export var basic_enemy_scene: PackedScene


func _ready():
	$Timer.timeout.connect(on_timer_timeout)
	pass # Replace with function body.


func on_timer_timeout():
	var player = get_tree().get_first_node_in_group("player") as Node2D
	
	if !player:
		return
	
	# Get a random direction and position to spawn enemy
	var random_direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	var spawn_position = player.global_position + (random_direction * SPAWN_RADIUS)

	# Get enemy instance
	var enemy = basic_enemy_scene.instantiate() as Node2D
	get_parent().add_child(enemy)
	enemy.global_position = spawn_position
