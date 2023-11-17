extends CanvasLayer

@export var arena_time_manager: Node

@onready var label = $%Label


func _process(delta):
	if !arena_time_manager:
		return
	
	var time_elapsed = arena_time_manager.get_time_elapsed()
	label.text = format_seconds_to_string(time_elapsed)


func format_seconds_to_string(seconds: float) -> String:
	var minutes = floor(seconds / 60)
	var remaining_seconds = seconds - (minutes * 60)
	# Format it so that there's two digits always for both minutes and seconds
	return ("%02d" % minutes) + " : " + ("%02d" % floor(remaining_seconds))
