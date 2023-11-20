extends Node2D

@export var health_component: HealthComponent
@export var sprite: Sprite2D

func _ready():
	$GPUParticles2D.texture = sprite.texture
	
	health_component.died.connect(on_died)


func on_died():
	# need to make it so that the animation plays while the enemy is not 
	# available anymore on player weapon search
	# so that player doesn't attack an enemy in death animation
	
	if !owner || not owner is Node2D:
		return
	
	# get a reference to the entities layer before we get out of it
	var entities_layer = get_tree().get_first_node_in_group("entities_layer")
	# get the position of where the parent died
	var death_position = owner.global_position
	
	# remove this component from the entity that died
	get_parent().remove_child(self)
	# add this death component directly to the entities layer so that its not connected to the entity that died
	entities_layer.add_child(self)
	global_position = death_position
	
	$AnimationPlayer.play("default")
	
