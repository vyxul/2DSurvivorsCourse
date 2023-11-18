extends Node

# Possible upgrades player can have
@export var upgrade_pool: Array[AbilityUpgrade]
@export var experience_manager: Node
@export var upgrade_screen_scene: PackedScene

# Upgrades that player already has
var current_upgrades = {}

func _ready():
	experience_manager.level_up.connect(on_level_up)


func on_level_up(current_level: int):
	# Randomly get one of the upgrades that the player can have
	var chosen_upgrade = upgrade_pool.pick_random() as AbilityUpgrade
	if chosen_upgrade == null:
		return

	var upgrade_screen_instance = upgrade_screen_scene.instantiate()
	add_child(upgrade_screen_instance)
	upgrade_screen_instance.set_ability_upgrades([chosen_upgrade] as Array[AbilityUpgrade])
	upgrade_screen_instance.upgrade_selected.connect(on_upgrade_selected)


func on_upgrade_selected(upgrade: AbilityUpgrade):
	apply_upgrade(upgrade)


func apply_upgrade(upgrade: AbilityUpgrade):
	# Check if player already had that upgrade
	var has_upgrade = current_upgrades.has(upgrade.id)
	# If player did not yet have that upgrade, create a new entry within the current_upgrades dictionary
	if !has_upgrade:
		# Create nested dictionary for the upgrade
		current_upgrades[upgrade.id] = {
			"resource": upgrade,
			"quantity": 1
		}
	# If player already had that upgrade, increment the counter keeping track of that upgrade
	else:
		current_upgrades[upgrade.id]["quantity"] += 1
		
	GameEvents.emit_ability_upgrade_added(upgrade, current_upgrades)
#	print_debug(current_upgrades)
