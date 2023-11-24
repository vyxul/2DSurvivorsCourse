extends CanvasLayer

signal transitioned_halfway

var skip_emit: bool = false

func transition():
	$AnimationPlayer.play("default")
#	print_debug("first part of scene transition")
	await transitioned_halfway
	skip_emit = true
#	print_debug("second part of scene transition")
	$AnimationPlayer.play_backwards("default")


func transition_to_scene(scene_path: String):
#	print_debug("starting scene switch to: %s" % scene_path)
	transition()
	await transitioned_halfway
	
#	print_debug("changing scene to: %s" % scene_path)
	get_tree().change_scene_to_file(scene_path)


func emit_transitioned_halfway():
#	print_debug("halfway through screen transition; skip_emit = %s" % skip_emit)
	if skip_emit:
#		print_debug("returning from emit function, skip_emit = %s" % skip_emit)
		skip_emit = false
		return
		
	transitioned_halfway.emit()
