extends CanvasLayer

var options_menu_scene = preload("res://Scenes/UI/options_menu.tscn")

func _ready():
	$%PlayButton.pressed.connect(on_play_pressed)
	$%OptionsButton.pressed.connect(on_options_pressed)
	$%QuitButton.pressed.connect(on_quit_pressed)


func on_play_pressed():
	get_tree().change_scene_to_file("res://Scenes/Main/main.tscn")


func on_options_pressed():
	var options_menu_instance = options_menu_scene.instantiate()
	add_child(options_menu_instance)
	options_menu_instance.back_pressed.connect(on_options_menu_closed.bind(options_menu_instance))


func on_quit_pressed():
	get_tree().quit()


func on_options_menu_closed(options_menu_instance: Node):
	options_menu_instance.queue_free()
