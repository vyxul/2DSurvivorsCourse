extends Node

@export var max_range: float

@export var sword_ability: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.timeout.connect(on_timer_timeout)


func on_timer_timeout():
	# Get reference to player
	var player = get_tree().get_first_node_in_group("player") as Node2D
	
	# Should never happen, but code just in case
	if !player:
		return
	
	# Get a list of enemies currently spawned in the game no matter the distance
	var enemies = get_tree().get_nodes_in_group("enemy")
	# Filter the list of enemies down to those within range of the player
	enemies = enemies.filter(func(enemy: Node2D):
		return (enemy.global_position.distance_squared_to(player.global_position) < pow(max_range, 2))
	)
	# If no enemies within range, then return
	if enemies.size() == 0:
		return

	# Get the closest enemy to the player
	enemies.sort_custom(func(a: Node2D, b: Node2D):
		var a_distance = a.global_position.distance_squared_to(player.global_position)
		var b_distance = b.global_position.distance_squared_to(player.global_position)
		return a_distance < b_distance
	)
	
	# Create instance of the sword ability scene and add it to the main scene
	var sword_instance = sword_ability.instantiate() as Node2D
	player.get_parent().add_child(sword_instance)
	# Spawn the sword on the enemy position
	sword_instance.global_position = enemies[0].global_position
	# Adjust the spawn so it spawns in a random position around that enemy
	# Vector2.RIGHT rotation is 0
	# rotated(randf_range(0, TAU)) is basically giving us a random rotation from 0 to 2*PI
	# TAU = PI * 2
	# Multiply it by 4 to give it some offset
	sword_instance.global_position += Vector2.RIGHT.rotated(randf_range(0, TAU)) * 4
	
	# Rotate the sword towards the enemy
	var enemy_direction = enemies[0].global_position - sword_instance.global_position
	sword_instance.rotation = enemy_direction.angle()
