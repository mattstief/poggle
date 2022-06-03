tool
extends Area2D

export(float) 	var circle_r:float = 30.0 	setget set_radius
export(int) 	var num_points:int = 30 	setget set_num_points

func set_radius(new_r) -> void:
	circle_r = new_r
	set_points()

func set_num_points(new_num) -> void:
	num_points = new_num
	set_points()

func set_points() -> void:
	var polygon:		Object 				= ConcavePolygonShape2D.new()
	var arr_of_points:	PoolVector2Array 	= calc_points()
	var valid_polygon:	bool 				= is_instance_valid(polygon)
	if valid_polygon:
		polygon.set_segments(arr_of_points)
		self.add_child(polygon)
	#poly.segments = calc_points()
	#me.pol polygon=calc_points()

func calc_points() -> PoolVector2Array:
	var radius:		float 				= self.get("circle_r")
	var radian_step:float 				= float(2.0*PI)/float(num_points)
	var points:		PoolVector2Array 	= []
	for i in range(num_points):
		var x:float = cos(radian_step*i) * radius
		var y:float = sin(radian_step*i) * radius
		var point:Vector2 = Vector2(x,y)
		points.append(point)
	return points

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_points()
	set_owner(get_tree().root)
	var in_editor:bool = (Engine.editor_hint)
	if in_editor:
		set_owner(get_tree().edited_scene_root)
