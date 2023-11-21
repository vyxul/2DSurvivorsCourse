extends Node


@export var experience_manager: Node
@export var upgrade_screen_scene: PackedScene
@export var upgrade_choice_limit: int = 3

# Upgrades that player already has
var current_upgrades = {}
var upgrade_pool: WeightedTable = WeightedTable.new()

var upgrade_axe = preload("res://Resources/Upgrades/axe.tres")
var upgrade_axe_damage = preload("res://Resources/Upgrades/axe_damage.tres")
var upgrade_axe_rate = preload("res://Resources/Upgrades/axe_rate.tres")
var upgrade_sword_rate = preload("res://Resources/Upgrades/sword_rate.tres")
var upgrade_sword_damage = preload("res://Resources/Upgrades/sword_damage.tres")
var player_move_speed = preload("res://Resources/Upgrades/player_move_speed.tres")

func _ready():
	upgrade_pool.add_item(upgrade_axe, 10)
	upgrade_pool.add_item(upgrade_sword_rate, 10)
	upgrade_pool.add_item(upgrade_sword_damage, 10)
	upgrade_pool.add_item(player_move_speed, 5)
	
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
			upgrade_pool.remove_item(upgrade)
		
	# pass in the upgrade
	# hard coded for now but if its axe, add the upgrades for the axe
	# can make it check if upgrade is Ability, and ability resource has array of related upgrades
	update_upgrade_pool(upgrade)
		
	GameEvents.emit_ability_upgrade_added(upgrade, current_upgrades)
#	print_debug(current_upgrades)


func update_upgrade_pool(chosen_upgrade: AbilityUpgrade):
	if chosen_upgrade.id == upgrade_axe.id:
		upgrade_pool.add_item(upgrade_axe_damage, 10)
		upgrade_pool.add_item(upgrade_axe_rate, 10)


func pick_upgrades() -> Array[AbilityUpgrade]:
	# need to keep track of what upgrades we will show on upgrade screen
	var chosen_upgrade_pool: Array[AbilityUpgrade] = []
	
	for i in upgrade_choice_limit:
		if upgrade_pool.items.size() == chosen_upgrade_pool.size():
			break
		
		# Randomly get one of the upgrades that the player can have
		var chosen_upgrade = upgrade_pool.pick_item(chosen_upgrade_pool)

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
