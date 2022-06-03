extends KinematicBody2D

var segments:Array
export(Resource) var segment_sprite:			Resource
export(Resource) var projectile_scene:			Resource
export var aim_segment_count:	int 	= 15
export var aim_step_time:		float 	= 0.05
var aim_sprite_scale:			Vector2 = Vector2(0.3, 0.3)
var rotation_direction:			int 	= 0
var rotation_speed:				float 	= 1.0
var default_rotation_offset:	float	= PI/float(2.0)

var projectile_speed:			float	= 1100.0
var projectile_gravity:			float 	= 1200.0

signal shoot_input(asset, rot, pos)
signal spawn_obj(obj)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#set_projectile_resource()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta:float) -> void:
	draw_arrow()

func _unhandled_input(_event: InputEvent) -> void:
	look_at_pointer()
	offset_rotation()
	if Input.is_action_pressed("spin down"):
		self.set("rotation_direction", 1)
	elif Input.is_action_pressed("spin up"):
		self.set("rotation_direction", -1)
	else:
		self.set("rotation_direction", 0)
	if Input.is_action_just_released("fire"):
		var success:bool = attempt_shot()
		if !success:
			print("cannot shoot")
	if Input.is_action_just_released("reset"):
		var err := get_tree().reload_current_scene()
		if err:
			print(err)

func look_at_pointer() -> void:
	var pointer:Vector2 = get_global_mouse_position()
	self.look_at(pointer)

func offset_rotation(offset:float = self.get("default_rotation_offset")) -> void:
	var curr_rotation:		float = self.get("rotation")
	var adjusted_rotation:	float = curr_rotation - offset
	self.set("rotation", adjusted_rotation)


func _physics_process(delta:float) -> void:
	var direction:		int = self.get("rotation_direction")
	var angular_speed:	float = self.get("rotation_speed")
	var rotation_amnt:	float = (direction * angular_speed * delta)
	self.rotate(rotation_amnt)

func attempt_shot() -> bool:
	var projectile_asset:	Resource = self.get("projectile_scene")
	var spawn_point:		Node2D	 = self.get_node_or_null("SpawnPoint")
	var valid_projectile:	bool 	 = is_instance_valid(projectile_asset)
	var valid_spawn:		bool	 = is_instance_valid(spawn_point)
	if (valid_projectile and valid_spawn):
		var current_rotation:float 		= self.get("rotation")
		var spawn_position:	 Vector2 	= spawn_point.get("global_position")
		emit_signal("shoot_input", projectile_asset, current_rotation, spawn_position)
		return true
	else:
		return false

func spawn_obj(obj:Object) -> Object:
	var instance:		Object 	= obj.instance()
	var valid_object:	bool 	= is_instance_valid(instance)
	if valid_object:
		return instance
	else:
		return null

func make_child(instance:Object, parent:Object) -> bool:
	var valid_instance:bool = is_instance_valid(instance)
	var valid_parent:  bool	= is_instance_valid(parent)
	if (valid_instance && valid_parent):
		parent.add_child(instance)
		return true
	else:
		return false

func draw_segment(global_pos:Vector2) -> void:
	var segment_arr:		Array 		= self.get("segments")
	var segment_scale:		Vector2	 	= self.get("aim_sprite_scale")
	var segment_alpha: 		float		= 1.0 - get_segment_proportion()
	var sprite_resource:	Resource 	= self.get("segment_sprite")
	var segment_instance:	Object		= spawn_obj(sprite_resource)
	var valid_segment:		bool		= is_instance_valid(segment_instance)
	if valid_segment:
		segment_instance.set("position", global_pos)
		segment_instance.set("scale", segment_scale)
		segment_instance.modulate.a = segment_alpha
		segment_arr.append(segment_instance)
		emit_signal("spawn_obj", segment_instance)

func get_segment_proportion() -> float:
	var current_count:	int 	= segments.size()
	var total_count:	int	  	= self.get("aim_segment_count")
	var ratio:			float 	= float(current_count) / float(total_count)
	return ratio

func clear_segments() -> void:
	var aim_arrow_segments:Array = self.get("segments")
	for segment in aim_arrow_segments:
		if is_instance_valid(segment):
			segment.queue_free()
	aim_arrow_segments.clear()

func draw_arrow() -> void:
	clear_segments()
	var spawn_point:Node2D 	= self.get_node_or_null("SpawnPoint")
	var valid_spawn:bool	= is_instance_valid(spawn_point)
	if valid_spawn:
		var initial_pos:		Vector2				= spawn_point.get("global_position")
		var barrel_rot:			float				= self.get("rotation")
		var arc_node_positions:	PoolVector2Array 	= get_arc_array(initial_pos, barrel_rot)
		for node_position in arc_node_positions:
			draw_segment(node_position)

func get_arc_array(start_position:Vector2, start_rotation:float) -> PoolVector2Array:
	var num_steps:	int				 = self.get("aim_segment_count")
	var time_step:	float			 = self.get("aim_step_time")
	var speed:		float 			 = self.get("projectile_speed")
	var grav:		float			 = self.get("projectile_gravity")
	var rotated_vel:Vector2			 = rotate_speed_y(speed, start_rotation)
	var arc:		PoolVector2Array = []
	for i in range(num_steps):
		var time:			float 	= (i * time_step)
		var offset:			Vector2 = offset_at_t(time, grav, rotated_vel)
		var node_position:	Vector2 = start_position + offset
		arc.append(node_position)
	return arc

static func rotate_speed_y(speed:float, radians:float) -> Vector2:
	var speed_vector:	Vector2 = Vector2(0.0, speed)
	var rotated:		Vector2 = speed_vector.rotated(radians)
	return rotated

static func offset_at_t(time:float, gravity:float, velocity:Vector2) -> Vector2:
	var gravity_displacement:	float 	= (0.5 * gravity * pow(time, 2.0))
	var x_displacement:			float 	= (velocity.x * time)
	var y_displacement:			float 	= ((velocity.y * time) + gravity_displacement)
	var offset:					Vector2 = Vector2(x_displacement, y_displacement)
	return offset

func DEBUG_reset_print_input():
	get("phantom_projectile").set("print_count", 0)
