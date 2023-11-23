extends Node

@export var end_screen_scene: PackedScene

var pause_menu_scene = preload("res://Scenes/UI/pause_menu.tscn")

func _ready():
	$%Player.health_component.died.connect(on_player_died)


func on_player_died():
	var end_screen_instance = end_screen_scene.instantiate()
	add_child(end_screen_instance)
	end_screen_instance.set_defeat()
	MetaProgression.save()


# this method will take care of inputs that haven't been handled by any other component
func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		add_child(pause_menu_scene.instantiate())
		get_tree().root.set_input_as_handled()
		
	# need to let godot know that this input has been handled here
	# and wont propogate through the tree
