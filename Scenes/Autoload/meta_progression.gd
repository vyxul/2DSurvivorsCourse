extends Node

const SAVE_FILE_PATH = "user://game.save"

# default data for when we have no save data
var save_data: Dictionary = {
	"meta_upgrade_currency": 0,
	"meta_upgrades": {}
}


func _ready():
	GameEvents.experience_vial_collected.connect(on_experience_collected)
	load_save_file()


# reset the save data back to the default
func clear():
	save_data = {
		"meta_upgrade_currency": 0,
		"meta_upgrades": {}
	}
	save()

func load_save_file():
	# if the save file doesn't exist
	if !FileAccess.file_exists(SAVE_FILE_PATH):
		return
		
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	# gets all the content of the file
	save_data = file.get_var()
	display_save()


func save():
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	# overwrites all the content of the file with the argument
	file.store_var(save_data)
	display_save()


func display_save():
	print_debug(save_data)


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
	save()


func get_meta_upgrade_currency() -> int:
	return save_data["meta_upgrade_currency"]


func has_upgrade(upgrade: MetaUpgrade) -> bool:
	return save_data["meta_upgrades"].has(upgrade.id)


# gets just the quantity of an upgrade in save_data
func get_upgrade_count(upgrade: MetaUpgrade) -> int:
	if !has_upgrade(upgrade):
		return 0
		
	return save_data["meta_upgrades"][upgrade.id]["quantity"]


# gets all the relevant data for the upgrade in save_data
# would be more useful if we had more than just quantity
func get_upgrade_data(upgrade: MetaUpgrade) -> Dictionary:
	# if player has not yet aquired that upgrade, return an empty dictionary
	if !has_upgrade(upgrade):
		return {}
		
	# else, return the dictionary correpsonding to that upgrade
	return save_data["meta_upgrades"][upgrade.id]


func remove_currency(number: int) -> int:
	save_data["meta_upgrade_currency"] -= number
	return get_meta_upgrade_currency()


func on_experience_collected(number: float):
	save_data["meta_upgrade_currency"] += number
