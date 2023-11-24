extends Node

# Half of viewport width with a little bit extra to avoid the enemies being seen spawning at the edges of the screen
const SPAWN_RADIUS = 375

@export var grey_rat_enemy_scene: PackedScene
@export var wizard_enemy_scene: PackedScene
@export var bat_enemy_scene: PackedScene
@export var arena_time_manager: Node

@export var enemy_spawn_time: float = 1

@onready var timer = $Timer

var base_spawn_time = 0
var number_to_spawn: int = 1
var enemy_table = WeightedTable.new()


func _ready():
	enemy_table.add_item(grey_rat_enemy_scene, 10)
	
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
		
		# in the case that the raycast ends a few pixels away from the wall,
		# the enemy will spawn with their collision shape inside the wall and can't move
		# check a little past where the raycast ends to ensure this doesn't happen
		var additional_check_offset = random_direction * 20
		
		# 1 is for the terrain layer
		var query_parameters = PhysicsRayQueryParameters2D.create(player.global_position, spawn_position + additional_check_offset, 1)
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
	
	for i in number_to_spawn:
		# Get the random enemy scene
		var enemy_scene = enemy_table.pick_item()
		# Get enemy instance
		var enemy = enemy_scene.instantiate() as Node2D
		
		var entities_layer = get_tree().get_first_node_in_group("entities_layer")
		entities_layer.add_child(enemy)
		enemy.global_position = get_spawn_position()


func on_arena_difficulty_increased(arena_difficulty: int):
	var time_off = (.1 / 12) * arena_difficulty
	time_off = min(time_off, .7)
#	print_debug("time_off = %f" % time_off)
	
	timer.wait_time = base_spawn_time - time_off


	if arena_difficulty == 1:
		enemy_table.add_item(bat_enemy_scene, 15)
	# at 3 * (5 secs) [15 secs], add wizards to enemy pool
	if arena_difficulty == 3:
		enemy_table.add_item(wizard_enemy_scene, 20)
		
	if (arena_difficulty % 2) == 0:
		number_to_spawn += 1
		print_debug("number to spawn = %d" % number_to_spawn)
