extends KinematicBody2D
export(float) var period:	float = 10.0
export(float) var amplitude:float
var tween:		Tween
var tween_enum:	int = 0

func collide() -> void:
	pass

func _ready() -> void:
	var amplitude_set:bool = self.get("amplitude")
	if not amplitude_set:
		guess_starting_amplitude()
	initialize_tween()

func guess_starting_amplitude() -> void:
	var start_pos:			Vector2	= self.get("global_position")
	var initial_x_offset:	float 	= start_pos.x
	var amp:			 	float 	= abs(initial_x_offset)
	self.set("amplitude", amp)

func initialize_tween():
	var new_tween:		Tween = Tween.new()
	var tween_exists:	bool  = is_instance_valid(new_tween)
	if tween_exists:
		self.add_child(new_tween)
		self.set("tween", new_tween)
		tween_loop(new_tween)

func tween_loop(twn:Tween) -> void:
	while(true):	#infinite loop
		var update:bool = update_tween()
		if update:
			var start:bool 	= twn.start()
			if start:
				yield(twn, "tween_completed")

func tween_property(start, end, obj, property_str, tween_obj,
duration = period/4.0, trans_type = Tween.TRANS_LINEAR, ease_type = Tween.EASE_IN_OUT) -> bool:
	if !(is_instance_valid(obj)):
		return false
	return tween_obj.interpolate_property(
	obj,
	property_str,
	start,
	end,
	duration,
	trans_type,
	ease_type)

func update_tween() -> bool:
	var start_pos:	Vector2 = self.get("global_position")
	var next_pos:	Vector2 = start_pos
	var offset:		float 	= 2.00 * self.get("amplitude")
	var state:		int 	= self.get("tween_enum")
	if state == 0:
		next_pos.x = next_pos.x - offset
		self.set("tween_enum", 1)
	elif state == 1:
		next_pos.x = next_pos.x + offset
		self.set("tween_enum", 0)
	var twn:			Tween = self.get("tween")
	var tween_exists:	bool  = is_instance_valid(twn)
	if tween_exists:
		return tween_property(start_pos, next_pos, self, "global_position", twn)
	else:
		return false
