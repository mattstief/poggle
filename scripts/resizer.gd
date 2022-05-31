extends Camera2D

var screen_size : Vector2 = Vector2()
var follow_shot : bool	  = true

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = OS.get_screen_size()

func _process(_delta) -> void:
	var curr_size = OS.get_screen_size()
	var screen_size_changed:bool = (curr_size != screen_size)
	if screen_size_changed:
		screen_size = curr_size
		OS.set_window_size(screen_size)

func _projectile_shot():
	pass
