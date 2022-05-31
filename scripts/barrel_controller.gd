extends KinematicBody2D

var segments:Array
export(Resource) var segment_sprite
export(Resource) var projectile_scene
export(Resource) var default_projectile_scene
export var aim_segment_count = 15
export var aim_step_time 	 = 0.05
var aim_sprite_scale 		 = Vector2(0.3, 0.3)
var rotation_direction  	 = 0
var rotation_speed 			 = 1

signal shoot_input(asset, rot, pos)
signal spawn_obj(obj)

# Called when the node enters the scene tree for the first time.
func _ready():
	set_projectile_resource()

func set_projectile_resource(resource = get("default_projectile_scene")):
	var no_default_projectile = !is_instance_valid(resource)
	if no_default_projectile:
		print("default projectile not set for barrel controller....\n falling back to base")
		resource = preload("res://prefabs/projectile1.tscn")
		set("default_projectile_scene", resource)
	set("projectile_scene", resource)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	draw_arrow()

func _unhandled_input(_event: InputEvent) -> void:
	look_at_pointer()
	if Input.is_action_pressed("spin down"):
		self.set("rotation_direction", 1)
	elif Input.is_action_pressed("spin up"):
		self.set("rotation_direction", -1)
	else:
		self.set("rotation_direction", 0)
	if Input.is_action_just_released("fire"):
		attempt_shot()
	if Input.is_action_just_released("reset"):
		var err = get_tree().reload_current_scene()
		if err:
			print(err)

func look_at_pointer():
	var pointer = get_global_mouse_position()
	var offset = PI/2
	self.look_at(pointer)
	self.set("rotation", self.get("rotation") - offset)

func _physics_process(delta):
	var rotation_amnt = get("rotation_direction") * get("rotation_speed")
	self.rotate(rotation_amnt * delta)

func attempt_shot():
	var projectile_asset 	  = get("projectile_scene")
	var valid_projectile:bool = is_instance_valid(projectile_asset)
	if valid_projectile:
		var rot = self.get("rotation")
		var pos = $SpawnPoint.get("global_position")
		emit_signal("shoot_input", projectile_asset, rot, pos)
		return 1
	else:
		return 0

func spawn_obj(obj):
	var instance = obj.instance()
	if is_instance_valid(instance):
		return instance
	else:
		return null

func make_child(instance, parent):
	var valid_instance:bool = is_instance_valid(instance)
	var valid_parent:  bool	= is_instance_valid(parent)
	if (valid_instance && valid_parent):
		parent.add_child(instance)
		return 1
	else:
		return 0

func draw_segment(global_pos:Vector2):
	var segment_instance = spawn_obj(get("segment_sprite"))
	var segment_arr 	 = get("segments")
	segment_instance.set("position", global_pos)
	segment_instance.set("scale", aim_sprite_scale)
	segment_instance.modulate.a = 1.0 - segment_proportion()
	segment_arr.append(segment_instance)
	emit_signal("spawn_obj", segment_instance)

func segment_proportion():
	var current_count = segments.size()
	var total_count	  = self.get("aim_segment_count")
	var ratio:float = float(current_count) / float(total_count)
	return ratio

func clear_segments():
	var aim_arrow_segments = get("segments")
	for segment in aim_arrow_segments:
		if is_instance_valid(segment):
			segment.queue_free()
	aim_arrow_segments.clear()

func draw_arrow():
	clear_segments()
	var initial_pos	= $SpawnPoint.get("global_position")
	var barrel_rot	= self.get("rotation")
	var rotated_vel	= rotated_vel_vec(1100, barrel_rot)
	var num_steps	= self.get("aim_segment_count")
	var time_step	= self.get("aim_step_time")
	var time:float	= 0.0
	for i in range(num_steps):
		time = i * time_step
		var offset:Vector2 = offset_at_t(time, 1200, rotated_vel)
		draw_segment(initial_pos + offset)

static func rotated_vel_vec(speed, angle):
	var speed_vector = Vector2(0, speed)
	return (speed_vector.rotated(angle))

static func offset_at_t(t, gravity, velocity:Vector2):
	var x_displacement = (velocity.x * t)
	var y_displacement = (velocity.y * t) + (0.5 * gravity * pow(t, 2.0))
	return Vector2(x_displacement, y_displacement)

func DEBUG_reset_print_input():
	get("phantom_projectile").set("print_count", 0)
