tool
extends CollisionPolygon2D

export(float) 	var circle_r:	float   = 30.0 setget set_radius
export(int) 	var num_points:	int 	= 30 setget set_num_points

func set_radius(new_r:float) -> void:
	circle_r = new_r
	set_points()

func set_num_points(new_num:int) -> void:
	num_points = new_num
	set_points()

func set_points() -> void:
	set_polygon(calc_points())

func calc_points() -> PoolVector2Array:
	var radian_step:float 				= float(2.0*PI)/float(num_points)
	var points:		PoolVector2Array 	= PoolVector2Array()
	for i in range(num_points):
		var x:float = cos(radian_step*i) * circle_r
		var y:float = sin(radian_step*i) * circle_r
		points.append(Vector2(x,y))
	return points

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var in_editor:bool = (Engine.editor_hint)
	if in_editor:
		set_points()
		set_owner(get_tree().root)
		set_owner(get_tree().edited_scene_root)

