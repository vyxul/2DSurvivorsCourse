extends Node2D

@export var fade_in_duration: float = .3
@export var fade_out_duration: float = .5

func _ready():
	pass


func start(text: String):
	$Label.text = text
	
	# make the text float up to place and fade into screen
	var tween = create_tween()
	tween.set_parallel()
	
	tween.tween_property(self, "global_position", global_position + (Vector2.UP * 16), fade_in_duration)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	# stop the parallel here
	tween.chain()
	
	# make the text float up and fade away
	tween.tween_property(self, "global_position", global_position + (Vector2.UP * 48), fade_out_duration)\
	.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "scale", Vector2.ZERO, fade_out_duration)\
	.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	# stop the parallel here
	tween.chain()
	
	# queue free when that tween is done with the last call
	tween.tween_callback(queue_free)
	
	# this tween is made at the same at as the other tween and starts at the same time
	# the timings for this tween fit within the first tween's first tween_property() call
	var scale_tween = create_tween()
	scale_tween.tween_property(self, "scale", Vector2.ONE * 1.5, fade_in_duration/2)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	scale_tween.tween_property(self, "scale", Vector2.ONE, fade_in_duration/2)\
	.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
