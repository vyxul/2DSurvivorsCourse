extends Node

@export_group("Axe Stats")
@export var max_range: float = 100
@export var axe_base_attack_rate: float = 5
@export var axe_base_attack_damage: float = 3

@export_group("Controller Setup")
@export var axe_ability_scene: PackedScene

var axe_attack_rate: float
var axe_attack_damage: float
var axe_attack_damage_multiplier: float = 1

func _ready():
	axe_attack_rate = axe_base_attack_rate
	axe_attack_damage = axe_base_attack_damage
	
	$Timer.wait_time = axe_attack_rate
	$Timer.timeout.connect(on_timer_timeout)
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)
	

func on_timer_timeout():
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if !player:
		return
	
	var foreground_layer = get_tree().get_first_node_in_group("foreground_layer")
	if !foreground_layer:
		return
	
	var axe_abilility_instance = axe_ability_scene.instantiate() as AxeAbility
	foreground_layer.add_child(axe_abilility_instance)
	axe_abilility_instance.global_position = player.global_position
	axe_abilility_instance.hitbox_component.damage = axe_base_attack_damage * axe_attack_damage_multiplier


func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if upgrade.id == "axe_rate":
		var percent_reduction = current_upgrades["axe_rate"]["quantity"] * .1
		$Timer.wait_time = axe_base_attack_rate * (1 - percent_reduction)
		# Need to call start since we currently have timer as NOT a one shot and won't get updates unless restarted
		$Timer.start()
		
		print_debug("Axe Timer wait_time = %f" % $Timer.wait_time)
		
	elif upgrade.id == "axe_damage":
		axe_attack_damage_multiplier = 1 + (current_upgrades["axe_damage"]["quantity"] * .10)
	
		print_debug("Axe Damage Multiplier = %f" % axe_attack_damage_multiplier)
