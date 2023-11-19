extends Node2D
class_name AxeAbility

const MAX_RADIUS = 100

@onready var hitbox_component: HitboxComponent = $HitboxComponent

var base_direction = Vector2.RIGHT

func _ready():
	# get a random base direction so that axe isn't always starting and ending at same direction
	base_direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	
	var tween = create_tween()
	
	# tween method will automatically call the function set in 1st argument
	# the passed argument will be calculated by a variable that goes from argument[1] to argument[2]
	# in this case, need to put arguments as float for the passed argument to be a float
	tween.tween_method(tween_method, 0.0, 2.0, 3)
	tween.tween_callback(queue_free)


func tween_method(rotations: float):
	# figure out how far the axe needs to be from the starting point
	# 2 is there because we put 2.0 for the number of rotations for axe to go to in the tween method argument
	var percent = rotations / 2
	var current_radius = percent * MAX_RADIUS
	# make it so that the axe goes through a whole circle within one rotation
	var current_direction = base_direction.rotated(rotations * TAU)
	# make it so that the axe rotates as it goes around according to what part of rotation it is on
	var current_rotation = rotations * TAU

	# set a default root position
	# if we want the axe to not follow player as it flies around, need to move the below block of code
	# to ready function with global root_position and player variables
	var root_position = Vector2.ZERO
	# get player position
	var player = get_tree().get_first_node_in_group("player") as Node2D
	# if no player (shouldnt happen), then return from function
	if !player:
		return
		
	# spawn axe at player position
	root_position = player.global_position
	# end of code block

	# move axe according to previously calculated direction and radius according to what rotation its on
	global_position = root_position + (current_direction * current_radius)
	# set axe rotation according to previously calculated rotation
	# could put setting and calculation on same line if wanted
	rotation = current_rotation
