extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_Button_button_up() -> void:
	var err = get_tree().change_scene("res://levels/level1.tscn")
	if err:
		print(err)
