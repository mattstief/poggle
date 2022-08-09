extends Node2D
signal ability_signal(arg)
var in_stasis:Array = []
var saved_vel:Array = []
var saved_grv:Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func try_ability(projectile:Node2D) -> void:
	if (in_stasis.size() <= 0):
		special_ability_begin(projectile)
	else:
		special_ability_end(projectile)

func special_ability_begin(projectile:Node2D) -> void:
	projectile.add_to_group("stasis")

	in_stasis.push_back(projectile)
	saved_vel.push_back(projectile.get("velocity"))
	saved_grv.push_back(projectile.get("gravity"))

	#stop projectile motion
	projectile.set("gravity", 0.0)
	projectile.set("velocity", Vector2(0.0,0.0))
	emit_signal("ability_signal", "expend shot")

func special_ability_end(projectile:Node2D) -> void:
	var release:Node2D = in_stasis.pop_back()
	var vel:Vector2 = saved_vel.pop_back()
	var grv: float = saved_grv.pop_back()
	release.set("velocity", vel)
	release.set("gravity", grv)
	release.remove_from_group("stasis")


func stasis_collision(collision_instance:KinematicCollision2D) -> void:
	deflect(collision_instance)


func deflect(collision_instance:KinematicCollision2D) -> void:
	var projectile_vel = collision_instance.collider_velocity()
	var resulting_vel  = saved_vel[0] + projectile_vel
	saved_vel[0] = resulting_vel
