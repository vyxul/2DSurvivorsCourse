extends CanvasLayer

@export var upgrades: Array[MetaUpgrade] = []

@onready var grid_container = %GridContainer
@onready var back_button = %BackButton

var meta_upgrade_card_scene = preload("res://Scenes/UI/meta_upgrade_card.tscn")


func _ready():
	back_button.pressed.connect(on_back_pressed)
	
	# removing any of the testing elements before actually using the node
	for child in grid_container.get_children():
		child.queue_free()
	
	for upgrade in upgrades:
		var meta_upgrade_card_instance = meta_upgrade_card_scene.instantiate()
		grid_container.add_child(meta_upgrade_card_instance)
		meta_upgrade_card_instance.set_meta_upgrade(upgrade)
		# need to defer the call since the positions won't be correct until the next frame for
		# position calculation
		meta_upgrade_card_instance.call_deferred("update_progress")


func on_back_pressed():
	ScreenTransition.transition_to_scene("res://Scenes/UI/main_menu.tscn")
