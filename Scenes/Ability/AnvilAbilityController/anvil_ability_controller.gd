extends Node

const BASE_RANGE = 100

@export_category("Anvil Stats")
@export var max_range: float = 150
@export var anvil_base_attack_rate: float = 5
@export var anvil_base_attack_damage: float = 5
@export var anvil_base_attack_count: int = 1

@export_group("Controller Setup")
@export var anvil_ability_scene: PackedScene

var anvil_attack_rate: float
var anvil_attack_damage: float
var anvil_attack_damage_multiplier: float = 1
var anvil_attack_count: int


func _ready():
	anvil_attack_rate = anvil_base_attack_rate
	anvil_attack_damage = anvil_base_attack_damage
	anvil_attack_count = anvil_base_attack_count

	$Timer.wait_time = anvil_attack_rate
	$Timer.timeout.connect(on_timer_timeout)
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)


func on_timer_timeout():
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if !player:
		return
		
	var direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	var additional_rotation_degrees = 360.0 / anvil_attack_count
	for i in anvil_attack_count:
		var adjusted_direction = direction.rotated(deg_to_rad(i * additional_rotation_degrees))
		
		var spawn_position = player.global_position + (adjusted_direction * randf_range(0, BASE_RANGE))
		
		var query_parameters = PhysicsRayQueryParameters2D.create(player.global_position, spawn_position, 1)
		var result = get_tree().root.world_2d.direct_space_state.intersect_ray(query_parameters)
		# if the ray collided with terrain
		# just spawn it at the terrain
		if !result.is_empty():
			spawn_position = result["position"]

		var anvil_ability_instance = anvil_ability_scene.instantiate()
		get_tree().get_first_node_in_group("foreground_layer").add_child(anvil_ability_instance)
		anvil_ability_instance.global_position = spawn_position
		anvil_ability_instance.hitbox_component.damage = anvil_attack_damage

func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if upgrade.id == "anvil_rate":
		var percent_reduction = current_upgrades["anvil_rate"]["quantity"] * .1
		anvil_attack_rate = anvil_base_attack_rate * (1 - percent_reduction)
		$Timer.wait_time = anvil_attack_rate
		# Need to call start since we currently have timer as NOT a one shot and won't get updates unless restarted
		$Timer.start()
		
		print_debug("Anvil Timer wait_time = %f" % $Timer.wait_time)
		
	elif upgrade.id == "anvil_damage":
		anvil_attack_damage_multiplier = 1 + (current_upgrades["anvil_damage"]["quantity"] * .2)
		anvil_attack_damage = anvil_base_attack_damage * anvil_attack_damage_multiplier
		print_debug("Anvil damage = %f" % anvil_attack_damage)
		
	elif upgrade.id == "anvil_count":
		anvil_attack_count += 1
