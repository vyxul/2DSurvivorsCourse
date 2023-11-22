extends Node

var save_data: Dictionary = {
	"meta_upgrade_currency": 0,
	"meta_upgrades": {}
}


func _ready():
	GameEvents.experience_vial_collected.connect(on_experience_collected)
	add_meta_upgrade(load("res://Resources/Meta_Upgrades/experience_gained.tres"))


func add_meta_upgrade(upgrade: MetaUpgrade):
	# if the player doesn't yet have that upgrade
	# add it and set to 0
	# makes sure that the code after this block will work
	if !save_data["meta_upgrades"].has(upgrade.id):
		save_data["meta_upgrades"][upgrade.id] = {
			"quantity": 0
		}

	# increment the counter for the upgrade quantity
	save_data["meta_upgrades"][upgrade.id]["quantity"] += 1
	print_debug(save_data)

func on_experience_collected(number: float):
	save_data["meta_upgrade_currency"] += number
