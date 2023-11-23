extends PanelContainer

@onready var name_label = $%NameLabel
@onready var description_label = $%DescriptionLabel
@onready var purchase_button = %PurchaseButton
@onready var progress_bar = %ProgressBar
@onready var progress_label = %ProgressLabel
@onready var vial_icon = %VialIcon
@onready var count_label = %CountLabel

var upgrade: MetaUpgrade
var vial_icon_start_position: Vector2
var vial_icon_position_offset: Vector2

func _ready():
	purchase_button.pressed.connect(on_purchase_pressed)
	
	vial_icon_position_offset = vial_icon.position

func set_meta_upgrade(upgrade: MetaUpgrade):
	self.upgrade = upgrade
	name_label.text = upgrade.title
	description_label.text = upgrade.description
	update_progress()


func select_card():
	$AnimationPlayer.play("selected")


func update_progress():
	# only data that is dependent on if we already ahve it in save data or not is quantity
	var current_quantity = 0
	var upgrade_data = MetaProgression.get_upgrade_data(upgrade)
	if MetaProgression.has_upgrade(upgrade):
		current_quantity = upgrade_data["quantity"]
		
	var is_maxed = current_quantity >= upgrade.max_quantity
	var meta_upgrade_currency = MetaProgression.get_meta_upgrade_currency()
	var percent = float(meta_upgrade_currency) / upgrade.experience_cost
	percent = clamp(percent, 0.0, 1.0)
	
	# the rest of the ui is based off of the upgrade that is passed in and not the save data
	
	# set the progres bar
	progress_bar.value = percent
	
	# set the button availability and text
	purchase_button.disabled = percent < 1 || is_maxed
	if is_maxed:
		purchase_button.text = "Max"
	
	# set the progress label to show text of numbers
	progress_label.text = "%d / %d" % [meta_upgrade_currency, upgrade.experience_cost]

	# move the vial icon to match the percent
	vial_icon_start_position = progress_bar.global_position
	var distance = percent * progress_bar.size.x
	vial_icon.global_position = (vial_icon_start_position + Vector2(distance, 0)) + vial_icon_position_offset
	
	# set the count of upgrades we have for the count label
	count_label.text = "x%d" % current_quantity
	
func on_purchase_pressed():
	if upgrade == null:
		return
	
	MetaProgression.add_meta_upgrade(upgrade)
	MetaProgression.remove_currency(upgrade.experience_cost)
	MetaProgression.save()
	
	get_tree().call_group("meta_upgrade_card", "update_progress")
	select_card()
