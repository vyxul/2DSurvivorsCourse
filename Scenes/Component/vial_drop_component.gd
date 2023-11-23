extends Node

@export_range(0,1) var drop_percent: float = .5
@export var experience_points: float = 1
@export var health_component: HealthComponent
@export var vial_scene: PackedScene

@export var experience_gained_upgrade: MetaUpgrade

func _ready():
	health_component.died.connect(on_died)


func on_died():
	var experience_gained_upgrade_count = MetaProgression.get_upgrade_count(experience_gained_upgrade)
	var adjusted_drop_percent = drop_percent * (1 + (experience_gained_upgrade.upgrade_percent_per_level * experience_gained_upgrade_count))
	
	if !vial_scene:
		return
		
	# in case the owner isnt a node2d for the global position
	if not owner is Node2D:
		return

	if randf() > adjusted_drop_percent:
		return

	var spawn_position = (owner as Node2D).global_position
	var vial_instance = vial_scene.instantiate() as Node2D
	
	var entities_layer = get_tree().get_first_node_in_group("entities_layer")
	entities_layer.add_child(vial_instance)
	vial_instance.experience_points = experience_points
	vial_instance.global_position = spawn_position
