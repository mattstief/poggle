extends Area2D
var caught_bodies:Array
var allow_repeat_bodies:bool = false
var action = "free ball"

signal projectile_caught

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_Area2D_body_entered(body):
	var allow_catch:bool = (self.get("allow_repeat_bodies") or is_unique(body))
	if allow_catch:
		emit_signal("projectile_caught", self)
	self.get("caught_bodies").append(body)

func is_unique(body):
	for elem in caught_bodies:
		var valid_element:bool = is_instance_valid(elem)
		if valid_element and (elem == body):
			return false
	return true
