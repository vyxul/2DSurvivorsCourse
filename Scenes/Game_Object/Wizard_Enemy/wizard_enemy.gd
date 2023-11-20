extends CharacterBody2D

@onready var velocity_component = $VelocityComponent
@onready var visuals = $Visuals

var is_moving: bool = false


func _process(delta):
	if is_moving:
		velocity_component.accelerate_to_player()
	else:
		velocity_component.decelerate()
		
	velocity_component.move(self)

	# turn the enemy to face the player
	var move_sign = sign(velocity.x)
	if move_sign != 0:
		visuals.scale.x = move_sign


func set_is_moving(moving: bool):
	is_moving = moving
