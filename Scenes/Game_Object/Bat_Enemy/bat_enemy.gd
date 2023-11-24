extends CharacterBody2D

@onready var velocity_component = $VelocityComponent
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var visuals = $Visuals


func _ready():
	hurtbox_component.hit.connect(on_hit)


func _process(delta):
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if !player:
		return
		
	# turn the sprite towards the player
	visuals.look_at(player.global_position)
	visuals.rotation_degrees += 90
	
	velocity_component.accelerate_to_player()
	velocity_component.move(self)


func on_hit():
	$RandomStreamPlayer2DComponent.play_random()
