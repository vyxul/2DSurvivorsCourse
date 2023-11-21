extends CharacterBody2D

@onready var velocity_component = $VelocityComponent
@onready var visuals = $Visuals


func _ready():
	$HurtboxComponent.hit.connect(on_hit)


func _process(delta):
	velocity_component.accelerate_to_player()
	velocity_component.move(self)

	# turn the enemy to face the player
	var move_sign = sign(velocity.x)
	if move_sign != 0:
		# do opposite since enemy is facing left by default
		visuals.scale.x = -move_sign


func on_hit():
	$HitRandomAudioPlayerComponent.play_random()
