extends CharacterBody2D

@onready var velocity_component = $VelocityComponent
@onready var health_component = $HealthComponent
@onready var damage_interval_timer = $DamageIntervalTimer
@onready var health_bar = $HealthBar
@onready var abilities = $Abilities
@onready var animation_player = $AnimationPlayer
@onready var visuals = $Visuals

var number_colliding_bodies = 0
var base_move_speed = 0
var base_move_speed_multiplier = 1
var move_speed_multiplier: float = 1

func _ready():
	base_move_speed = velocity_component.move_speed
	
	$CollisionArea2D.body_entered.connect(on_body_entered)
	$CollisionArea2D.body_exited.connect(on_body_exited)
	damage_interval_timer.timeout.connect(on_damage_interval_timer_timeout)
	health_component.health_changed.connect(on_health_changed)
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)
	update_health_display()

func _process(delta):
	var movement_vector: Vector2 = get_movement_vector()
	var direction = movement_vector.normalized()

	velocity_component.accelerate_in_direction(direction)
	velocity_component.move(self)
	
	# face the player the correct way that they are moving
	var move_sign = sign(movement_vector.x)
	if move_sign != 0:
		visuals.scale.x = move_sign
	# can make it even shorter using below but above is good example of using sign function
	# if movement_vector.x != 0:
	#	 visuals.scale.x = movement_vector.x
			
	if movement_vector.x != 0 or movement_vector.y != 0:
		animation_player.play("walk")
	else:
		animation_player.play("RESET")

func get_movement_vector():
	var x_movement = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var y_movement = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	
	return Vector2(x_movement, y_movement)


func check_deal_damage():
	if number_colliding_bodies == 0 || !damage_interval_timer.is_stopped():
		return
		
	health_component.damage(1)
	damage_interval_timer.start()
	
#	print_debug("Player Health = %d" % health_component.current_health)


func update_health_display():
	health_bar.value = health_component.get_health_percent()


func on_body_entered(other_body: Node2D):
	number_colliding_bodies += 1
	check_deal_damage()
	
	
func on_body_exited(other_body: Node2D):
	number_colliding_bodies -= 1


func on_damage_interval_timer_timeout():
	check_deal_damage()


func on_health_changed():
	GameEvents.emit_player_damaged()
	update_health_display()


func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	# if the chosen upgrade is of type ability, then add an instance of it
	if upgrade is Ability:
		var ability_scene = upgrade.ability_controller_scene as PackedScene
		var ability_instance = ability_scene.instantiate()
		abilities.add_child(ability_instance)

	elif upgrade.id == "player_move_speed":
		move_speed_multiplier = base_move_speed_multiplier + \
					(current_upgrades[upgrade.id]["quantity"] * .1)
		velocity_component.move_speed = base_move_speed * move_speed_multiplier
		print_debug("New player move speed = %d" % velocity_component.move_speed)
