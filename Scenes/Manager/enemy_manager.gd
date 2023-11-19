extends Node

# Half of viewport width with a little bit extra to avoid the enemies being seen spawning at the edges of the screen
const SPAWN_RADIUS = 375

@export var basic_enemy_scene: PackedScene
@export var arena_time_manager: Node

@export var enemy_spawn_time: float = 1

@onready var timer = $Timer

var base_spawn_time = 0

func _ready():
	timer.wait_time = enemy_spawn_time
	base_spawn_time = timer.wait_time
	
	timer.timeout.connect(on_timer_timeout)
	arena_time_manager.arena_difficulty_increased.connect(on_arena_difficulty_increased)


func get_spawn_position() -> Vector2:
	var player = get_tree().get_first_node_in_group("player") as Node2D
	
	if !player:
		return Vector2.ZERO
		
	var spawn_position = Vector2.ZERO
	var random_direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	
	# loop through 4 times to find valid spawn position, will do increments of 90 degrees from the random direction to find spawn
	# if all 4 directions are invalid, just spawn at Vector2.ZERO
	for i in 4:
		# Get a random direction and position to spawn enemy
		spawn_position = player.global_position + (random_direction * SPAWN_RADIUS)
			
		# 1 is for the terrain layer
		var query_parameters = PhysicsRayQueryParameters2D.create(player.global_position, spawn_position, 1)
		var result = get_tree().root.world_2d.direct_space_state.intersect_ray(query_parameters)
		
		# means that the ray didn't have any collision and is a valid spawn position
		if result.is_empty():
			break
		# means that the ray had a collision with something that has terrain layer, will need to try next spawn position if its valid
		else:
			random_direction = random_direction.rotated(deg_to_rad(90))

	return spawn_position

func on_timer_timeout():
	timer.start()
	
	var player = get_tree().get_first_node_in_group("player") as Node2D
	
	if !player:
		return
	
	# Get enemy instance
	var enemy = basic_enemy_scene.instantiate() as Node2D
	
	var entities_layer = get_tree().get_first_node_in_group("entities_layer")
	entities_layer.add_child(enemy)
	enemy.global_position = get_spawn_position()


func on_arena_difficulty_increased(arena_difficulty: int):
	var time_off = (.1 / 12) * arena_difficulty
	time_off = min(time_off, .7)
#	print_debug("time_off = %f" % time_off)
	
	timer.wait_time = base_spawn_time - time_off
