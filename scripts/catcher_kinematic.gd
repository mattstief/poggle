extends KinematicBody2D
export(float) var period = 10.0
export(float) var amplitude
var tween
var tween_enum = 0

# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
func collide():
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !self.get("amplitude"):
		amplitude = abs(self.get("global_position").x)
	var new_tween = Tween.new()
	self.add_child(new_tween)
	self.set("tween", new_tween)
	var tween_exists:bool = is_instance_valid(self.get("tween"))
	if tween_exists:
		tween_loop()

func tween_loop():
	while(true):
		update_tween()
		tween.start()
		yield(tween, "tween_completed")

func tween_property(start, end, obj, property_str, tween_obj,
duration = period/4.0, trans_type = Tween.TRANS_LINEAR, ease_type = Tween.EASE_IN_OUT):
	if !(is_instance_valid(obj)):
		return 0
	return tween_obj.interpolate_property(
	obj,
	property_str,
	start,
	end,
	duration,
	trans_type,
	ease_type)

func update_tween():
	var state = self.get("tween_enum")
	var start_pos = self.get("global_position")
	var next_pos = start_pos
	var offset = 2.00 * amplitude
	if state == 0:
		next_pos.x = next_pos.x - offset
		self.set("tween_enum", 1)
	elif state == 1:
		next_pos.x = next_pos.x + offset
		self.set("tween_enum", 0)
	tween_property(start_pos, next_pos, self, "global_position", tween)
