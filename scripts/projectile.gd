extends KinematicBody2D

var velocity = Vector2()
var speed = 0
var gravity = 0
var bounciness
var print_count = 0
var bounce_mod = -0.005

signal projectile_despawn()

func _on_VisibilityNotifier2D_viewport_exited(_viewport):
	print("projectile despawn")
	yield(get_tree().create_timer(0.2), "timeout")
	emit_signal("projectile_despawn")
	queue_free()

func _physics_process(delta):
	var v = self.get("velocity")
	v = apply_gravity(v, delta)
	self.set("velocity", v)
	var collision = move_and_collide(self.get("velocity") * delta)
	if collision:
		collide(collision)

# Called when the node enters the scene tree for the first time.
func _ready():
	set_initial_velocity(self.get("speed"))
	var light = get_node_or_null("Light2D")
	if light:
		light.twinkle = false
		light.energy_floor = 0.5

func set_initial_velocity(sp):
	var speed_vector 	 = Vector2(0, sp)
	var initial_velocity = speed_vector.rotated(self.get("rotation"))
	self.set("velocity", initial_velocity)

func collide(collision_instance):
	deflect(collision_instance)
	var other_obj = collision_instance.get("collider")
	other_obj.collide()
	bounciness = bounciness + bounce_mod


func deflect(collision_instance):
		#make_visibility_timer()
	var curr_vel 				 = self.get("velocity")
	var norm 				 	 = collision_instance.get("normal")
	var max_deflect_velocity 	 = self.get("velocity").bounce(norm)
	var deflect_velocity:Vector2 = lerp(curr_vel, max_deflect_velocity, bounciness)
	set("velocity", deflect_velocity)

func apply_gravity(vel, time):
	vel.y = vel.y + (gravity * time)
	return vel

func DEBUG_print(vec2:Vector2):
	if print_count < 20:
		print("y-x: ", (vec2.y - vec2.x))
		print_count = print_count + 1
