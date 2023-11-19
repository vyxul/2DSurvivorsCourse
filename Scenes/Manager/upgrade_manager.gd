extends Node

# Possible upgrades player can have
@export var upgrade_pool: Array[AbilityUpgrade]
@export var experience_manager: Node
@export var upgrade_screen_scene: PackedScene

# Upgrades that player already has
var current_upgrades = {}

func _ready():
	experience_manager.level_up.connect(on_level_up)


func apply_upgrade(upgrade: AbilityUpgrade):
	# Check if player already had that upgrade
	var has_upgrade = current_upgrades.has(upgrade.id)
	var current_quantity = 0
	# If player did not yet have that upgrade, create a new entry within the current_upgrades dictionary
	if !has_upgrade:
		current_quantity = 1
		
		# Create nested dictionary for the upgrade
		current_upgrades[upgrade.id] = {
			"resource": upgrade,
			"quantity": current_quantity
		}
	# If player already had that upgrade, increment the counter keeping track of that upgrade
	else:
		current_upgrades[upgrade.id]["quantity"] += 1
		current_quantity = current_upgrades[upgrade.id]["quantity"]
	
	print_debug("Upgrade id = %s, quantity = %d" % [upgrade.id, current_quantity])
	
	# Check to see if the upgrade has reached the max quantity it is allowed to reach
	# If yes, then remove it from the upgrade pool
	# If max quantity is 0, then it is meant to be infinite stacking
	if upgrade.max_quantity > 0:
		if current_quantity >= upgrade.max_quantity:
			print_debug("Upgrade id = %s, max_quantity = %d: has been removed from upgrade pool" % [upgrade.id, upgrade.max_quantity])
			#upgrade_pool.erase(upgrade)
			# not using erase since there might be multiple of the same upgrade in the pool for some reason
			# use filter to be sure that its gone
			upgrade_pool = upgrade_pool.filter(func (pool_upgrade):
				return pool_upgrade.id != upgrade.id
			)
		
	GameEvents.emit_ability_upgrade_added(upgrade, current_upgrades)
#	print_debug(current_upgrades)


func pick_upgrades() -> Array[AbilityUpgrade]:
	# need filtered array to prevent same ability showing up multiple times in one upgrade screen
	var filtered_upgrade_pool = upgrade_pool.duplicate()
	# need to keep track of what upgrades we will show on upgrade screen
	var chosen_upgrade_pool: Array[AbilityUpgrade] = []
	
	for i in 2:
		# if no upgrades left in pool, leave the loop
		if filtered_upgrade_pool.size() == 0:
			break
		
		# Randomly get one of the upgrades that the player can have
		var chosen_upgrade = filtered_upgrade_pool.pick_random() as AbilityUpgrade
		
		# filter function will iterate through every element within that array
		# at each element, it will be given as an argument to the inline function
		# if the function returns true, that element will stay in the new filtered array
		filtered_upgrade_pool = filtered_upgrade_pool.filter(func (upgrade):
			return upgrade.id != chosen_upgrade.id
		)

		# add the previously chosen upgrade to the chosen upgrade pool to pick
		chosen_upgrade_pool.append(chosen_upgrade)
		
	return chosen_upgrade_pool


func on_level_up(current_level: int):
	var upgrade_screen_instance = upgrade_screen_scene.instantiate()
	var chosen_upgrade_pool = pick_upgrades()
	add_child(upgrade_screen_instance)
	upgrade_screen_instance.set_ability_upgrades(chosen_upgrade_pool as Array[AbilityUpgrade])
	upgrade_screen_instance.upgrade_selected.connect(on_upgrade_selected)



func on_upgrade_selected(upgrade: AbilityUpgrade):
	apply_upgrade(upgrade)
