extends KinematicBody2D

var velocity:	Vector2 = Vector2()
var speed:		float 	= 0
var gravity:	float 	= 0
var bounciness:	float 	= 1.0
var bounce_mod:	float 	= -0.005

signal projectile_despawn()

func _on_VisibilityNotifier2D_viewport_exited(_viewport) -> void:
	print("projectile despawn")
	yield(get_tree().create_timer(0.2), "timeout")
	emit_signal("projectile_despawn")
	queue_free()

func _physics_process(delta) -> void:
	var v:Vector2 = self.get("velocity")
	v = apply_gravity(v, delta)
	self.set("velocity", v)
	var adjusted_vel:	Vector2 				= self.get("velocity") * delta
	var collision:		KinematicCollision2D 	= move_and_collide(adjusted_vel)
	var valid_collision:bool 					= is_instance_valid(collision)
	if valid_collision:
		collide(collision)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("projectile")
	var speed_scalar = self.get("speed")
	set_initial_velocity(speed_scalar)
	var light:Light2D = get_node_or_null("Light2D")
	var valid_light:bool = is_instance_valid(light)
	if valid_light:
		light.twinkle = false
		light.energy_floor = 0.5

func set_initial_velocity(sp:float) -> void:
	var curr_rotation:		float   = self.get("rotation")
	var speed_vector:		Vector2 = Vector2(0, sp)
	var initial_velocity:	Vector2 = speed_vector.rotated(curr_rotation)
	self.set("velocity", initial_velocity)

func collide(collision_instance:KinematicCollision2D) -> void:
	deflect(collision_instance)
	var other_obj = collision_instance.get("collider")
	other_obj.collide()
	adjust_bounciness()

func adjust_bounciness() -> void:
	var curr_bounce:  	float = self.get("bounciness")
	var bounce_offset:	float = self.get("bounce_mod")
	var new_bounce: 	float = curr_bounce + bounce_offset
	self.set("bounciness", new_bounce)

func deflect(collision_instance:KinematicCollision2D) -> void:
	var curr_vel:				Vector2 = self.get("velocity")
	var norm:					Vector2 = collision_instance.get("normal")
	var max_deflect_velocity:	Vector2 = self.get("velocity").bounce(norm)
	var deflect_velocity:		Vector2 = lerp(curr_vel, max_deflect_velocity, bounciness)
	self.set("velocity", deflect_velocity)

func apply_gravity(vel:Vector2, time:float) -> Vector2:
	vel.y = vel.y + (gravity * time)
	return vel
