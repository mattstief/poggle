extends Node2D
signal ability_signal(arg)
var in_stasis:Array = []
var saved_vel:Array = []
var saved_grv:Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func try_ability(projectile:Node2D) -> void:
	special_ability(projectile)

func special_ability(projectile:Node2D) -> void:
	in_stasis.push_back(projectile)
	saved_vel.push_back(projectile.get("velocity"))
	saved_grv.push_back(projectile.get("gravity"))

	#stop projectile motion
	projectile.set("gravity", 0.0)
	projectile.set("velocity", Vector2(0.0,0.0))
	emit_signal("ability_signal", "action")
	pass
