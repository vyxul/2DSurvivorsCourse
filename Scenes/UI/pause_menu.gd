extends CanvasLayer

@onready var panel_container = $MarginContainer/PanelContainer

var options_menu_scene = preload("res://Scenes/UI/options_menu.tscn")

var is_closing: bool = false


func _ready():
	get_tree().paused = true
	
	# set the pivot offset so that the panel animates as if its growing from
	# center instead of top-left corner
	# have to do it in code since not able to do it in gui editor since panel_container
	# is under a margin container and restricts that change
	panel_container.pivot_offset = panel_container.size / 2
	
	%ResumeButton.pressed.connect(on_resume_pressed)
	%OptionsButton.pressed.connect(on_options_pressed)
	%QuitButton.pressed.connect(on_quit_pressed)
	
	
	$AnimationPlayer.play("default")
	
	var tween = create_tween()
	# need the first tween property to ensure that the panel_container scale is
	# properly set to 0 before we do the tween animation
	tween.tween_property(panel_container, "scale", Vector2.ZERO, 0)
	tween.tween_property(panel_container, "scale", Vector2.ONE, .3)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)


# this method will take care of inputs that haven't been handled by any other component
func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		close()
		get_tree().root.set_input_as_handled()
		
	# need to let godot know that this input has been handled here
	# and wont propogate through the tree


func close():
	if is_closing:
		return
	
	is_closing = true
	
	$AnimationPlayer.play_backwards("default")
	
	var tween = create_tween()
	# need the first tween property to ensure that the panel_container scale is
	# properly set to 1 before we do the tween animation
	tween.tween_property(panel_container, "scale", Vector2.ONE, 0)
	tween.tween_property(panel_container, "scale", Vector2.ZERO, .3)\
	.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)

	await tween.finished
	
	get_tree().paused = false
	queue_free()


func on_resume_pressed():
	close()


func on_options_pressed():
	ScreenTransition.transition()
	await ScreenTransition.transitioned_halfway
	
	var options_menu_instance = options_menu_scene.instantiate()
	add_child(options_menu_instance)
	options_menu_instance.back_pressed.connect(on_options_back_pressed.bind(options_menu_instance))


func on_quit_pressed():
	ScreenTransition.transition()
	await ScreenTransition.transitioned_halfway
	
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/UI/main_menu.tscn")


func on_options_back_pressed(options_menu_instance: Node):
	options_menu_instance.queue_free()


