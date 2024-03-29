extends Node2D

@onready var collision_shape_2d = $Area2D/CollisionShape2D
@onready var sprite = $Sprite2D

var experience_points: float = 1

func _ready():
	$Area2D.area_entered.connect(on_area_entered)
	pass # Replace with function body.


func tween_collect(percent: float, start_position: Vector2):
	var player = get_tree().get_first_node_in_group("player")
	if !player:
		return
		
	global_position = start_position.lerp(player.global_position, percent)
	var direction_from_start = player.global_position - start_position
	
	var target_rotation = direction_from_start.angle() + deg_to_rad(90)
	rotation = lerp_angle(rotation, target_rotation, 1 - exp(-2 * get_process_delta_time()))


func collect():
	GameEvents.emit_experience_vial_collected(experience_points)
	queue_free()


func disable_collision():
	collision_shape_2d.disabled = true


func on_area_entered(other_area: Area2D):
	Callable(disable_collision).call_deferred()
	
	var tween = create_tween()
	# set parallel makes all the tween tweeners (adjustments) happen at the same time
	tween.set_parallel()
	# .set_ease is just to change how strong the method is at certain times
	# from https://easings.net/en
	# purpose is just to make the vial flying to player look better
	tween.tween_method(tween_collect.bind(global_position), 0.0, 1.0, .5)\
	.set_ease(Tween.EASE_IN)\
	.set_trans(Tween.TRANS_BACK)
	# since this is running pararell to the tween_method, 
	# delaying it so that it ends at the same time
	tween.tween_property(sprite, "scale", Vector2.ZERO, .15).set_delay(.35)
	# chain makes it so that any tweeners after it will wait for all 
	# other tweeners to finish before executing
	tween.chain()
	tween.tween_callback(collect)

	$RandomStreamPlayer2DComponent.play_random()
