extends Node

@export_category("Sword Stats")
@export var max_range: float = 150
@export var sword_base_attack_rate: float = 1.5
@export var sword_base_attack_damage: float = 1

@export_group("Controller Setup")
@export var sword_ability: PackedScene

var sword_attack_rate: float
var sword_attack_damage: float
var sword_attack_damage_multiplier: float = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	sword_attack_rate = sword_base_attack_rate
	sword_attack_damage = sword_base_attack_damage
	
	$Timer.wait_time = sword_attack_rate
	$Timer.timeout.connect(on_timer_timeout)
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)


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
	var sword_instance = sword_ability.instantiate() as SwordAbility
	var foreground_layer = get_tree().get_first_node_in_group("foreground_layer")
	foreground_layer.add_child(sword_instance)
	sword_instance.hitbox_component.damage = sword_base_attack_damage * sword_attack_damage_multiplier
	
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


func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if upgrade.id == "sword_rate":
		var percent_reduction = current_upgrades["sword_rate"]["quantity"] * .1
		$Timer.wait_time = sword_base_attack_rate * (1 - percent_reduction)
		# Need to call start since we currently have timer as NOT a one shot and won't get updates unless restarted
		$Timer.start()
		
		print_debug("Sword Timer wait_time = %f" % $Timer.wait_time)
		
	elif upgrade.id == "sword_damage":
		sword_attack_damage_multiplier = 1 + (current_upgrades["sword_damage"]["quantity"] * .15)
	
		print_debug("Sword Damage Multiplier = %f" % sword_attack_damage_multiplier)
