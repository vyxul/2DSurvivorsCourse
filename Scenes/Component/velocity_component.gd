extends Node

@export var move_max_speed: int = 40
@export var acceleration: float = 5

var velocity = Vector2.ZERO


func accelerate_to_player():
	var owner_node2d = owner as Node2D
	if !owner_node2d:
		return

	var player = get_tree().get_first_node_in_group("player") as Node2D
	if !player:
		return
		
	var direction = (player.global_position - owner_node2d.global_position).normalized()
	accelerate_in_direction(direction)


func accelerate_in_direction(direction: Vector2):
	var desired_velocity = direction * move_max_speed
	# using linear interpolation (lerp) we can make it like the enemy is homing on on player
	# acceleration affects how strong the homing effect is
	velocity = velocity.lerp(desired_velocity, 1 - exp(-acceleration * get_process_delta_time()))


func decelerate():
	accelerate_in_direction(Vector2.ZERO)


func move(character_body: CharacterBody2D):
	character_body.velocity = velocity
	character_body.move_and_slide()
	# will only be different from the code 2 lines above if the character_body collides with something
	velocity = character_body.velocity
