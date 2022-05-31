tool
extends Area2D

export(float) 	var circle_r   = 30 setget set_radius
export(int) 	var num_points = 30 setget set_num_points

func set_radius(new_r):
	circle_r = new_r
	set_points()

func set_num_points(new_num):
	num_points = new_num
	set_points()

func set_points():
	var poly = ConcavePolygonShape2D.new()
	poly.set_segments(calc_points())
	self.add_child(poly)
	#poly.segments = calc_points()
	#me.pol polygon=calc_points()

func calc_points():
	var radian_step = float(2.0*PI)/float(num_points)
	var points = []
	for i in range(num_points):
		var x = cos(radian_step*i) * circle_r
		var y = sin(radian_step*i) * circle_r
		points.append(Vector2(x,y))
	return points

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_points()
	set_owner(get_tree().root)
	if Engine.editor_hint:
		set_owner(get_tree().edited_scene_root)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
