extends Area2D
var caught_bodies:		Array
var allow_repeat_bodies:bool 	= false
var action:				String 	= "free ball"

signal projectile_caught

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_Area2D_body_entered(body:KinematicBody2D) -> void:
	var allow_catch:bool = (self.get("allow_repeat_bodies") or is_unique(body))
	var is_shot:bool = body.is_in_group("projectile")
	if allow_catch and is_shot:
		emit_signal("projectile_caught", self)
	self.get("caught_bodies").append(body)

func is_unique(body:KinematicBody2D) -> bool:
	for elem in caught_bodies:
		var valid_element:bool = is_instance_valid(elem)
		if valid_element and (elem == body):
			return false
	return true
