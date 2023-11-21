extends PanelContainer

signal selected

@onready var name_label = $%NameLabel
@onready var description_label = $%DescriptionLabel

var disabled = false

func _ready():
	gui_input.connect(on_gui_input)
	mouse_entered.connect(on_mouse_entered)
	GameEvents.all_upgrade_cards_loaded.connect(on_all_upgrade_cards_loaded)


func play_in(delay: float = 0):
	modulate = Color.TRANSPARENT
	scale = Vector2.ZERO
	await get_tree().create_timer(delay).timeout
	$AnimationPlayer.play("in")


func play_discard():
	$AnimationPlayer.play("discard")


func set_ability_upgrade(upgrade: AbilityUpgrade):
	name_label.text = upgrade.name
	description_label.text = upgrade.description


func select_card():
	disabled = true
	$AnimationPlayer.play("selected")
	
	for other_card in get_tree().get_nodes_in_group("upgrade_card"):
		if other_card == self:
			continue
			
		other_card.play_discard()
	
	await $AnimationPlayer.animation_finished
	selected.emit()


func on_gui_input(event: InputEvent):
	if disabled:
		return
	
	if Input.is_action_just_pressed("left_click"):
		select_card()


func on_mouse_entered():
	if disabled:
		return
		
	$HoverAnimationPlayer.play("hover")


func on_all_upgrade_cards_loaded():
	# gives a little delay after all the cards are shown before player can click on them
	# to prevent spam misclicking
	await get_tree().create_timer(.1).timeout
	mouse_filter = Control.MOUSE_FILTER_STOP
