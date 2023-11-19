extends Node

@export_group("Axe Stats")
@export var max_range: float = 100
@export var axe_base_attack_rate: float = 5
@export var axe_base_attack_damage: float = 3

@export_group("Controller Setup")
@export var axe_ability_scene: PackedScene

var axe_attack_rate: float
var axe_attack_damage: float

func _ready():
	axe_attack_rate = axe_base_attack_rate
	axe_attack_damage = axe_base_attack_damage
	
	$Timer.wait_time = axe_attack_rate
	$Timer.timeout.connect(on_timer_timeout)
	

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
	axe_abilility_instance.hitbox_component.damage = axe_attack_damage
