extends CanvasLayer

@onready var title_label = %TitleLabel
@onready var description_label = %DescriptionLabel
@onready var panel_container = %PanelContainer

func _ready():
	panel_container.pivot_offset = panel_container.size / 2
	panel_container.scale = Vector2.ZERO
	
	var tween = create_tween()
	# need a tween setting scale to zero in 0 seconds due to a Godot quirk
	# tweens wont happen until the scale is reset (back to (1, 1))
	# and so in between us setting scale to (0, 0) and creating the tween
	# to go to (1, 1), godot resets the scale
	# this is just a workaround
	tween.tween_property(panel_container, "scale", Vector2.ZERO, 0)
	tween.tween_property(panel_container, "scale", Vector2.ONE, .3)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	get_tree().paused = true
	$%ContinueButton.pressed.connect(on_continue_button_pressed)
	$%QuitButton.pressed.connect(on_quit_button_pressed)


func set_defeat():
	title_label.text = "Defeat"
	description_label.text = "You lost!"
	play_jingle(true)


func play_jingle(defeat: bool = false):
	if defeat:
		$DefeatStreamPlayer.play()
	else:
		$VictoryStreamPlayer.play()


func on_continue_button_pressed():
	ScreenTransition.transition_to_scene("res://Scenes/UI/meta_menu.tscn")
	# doing this await so that game doesn't unpause until it has transitioned
	await ScreenTransition.transitioned_halfway
	get_tree().paused = false


func on_quit_button_pressed():
	ScreenTransition.transition_to_scene("res://Scenes/UI/main_menu.tscn")
	# doing this await so that game doesn't unpause until it has transitioned
	await ScreenTransition.transitioned_halfway
	get_tree().paused = false
