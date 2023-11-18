extends Node2D


func _ready():
	$Area2D.area_entered.connect(on_area_entered)
	pass # Replace with function body.


func on_area_entered(other_area: Area2D):
	GameEvents.emit_experience_vial_collected(2)
	queue_free()
