extends Node2D
export(Resource) var label_template:Resource
var tweened_objs:			Array
var randomize_modulates:	Array
var col_change_time:		float 	= 0.15
var change_time_counter:	float 	= 0.0
var free_ball_text_offset:	Vector2 = Vector2(-1010, 0)
var free_ball_text_scale: 	Vector2 = Vector2(0,0)
var free_ball_text_scale2:	Vector2 = Vector2(21,21)
signal UI_signal(arg)

func _process(delta:float) -> void:
	var timer_val:float = self.get("change_time_counter")
	timer_val = timer_val + delta
	self.set("change_time_counter", timer_val)
	var trigger_time:	float = self.get("col_change_time")
	var obj_arr:		Array = self.get("randomize_modulates")
	if timer_val > trigger_time:
		for node in obj_arr:
			if is_instance_valid(node):
				var new_color:Color = get_rand_color()
				node.set("modulate", new_color)
		self.set("change_time_counter", 0.0)

func tween_property(start, end, obj, property_str, tween = $Tween,
duration = 1.0, trans_type = Tween.TRANS_SINE, ease_type = Tween.EASE_IN_OUT) -> bool:
	if !(is_instance_valid(obj)):
		return false
	return tween.interpolate_property(
	obj,
	property_str,
	start,
	end,
	duration,
	trans_type,
	ease_type)

func draw_event(arg:String = "default", event_origin:Object = self) -> void:
	if (arg == "free ball"):
		var fx_node:	Object = add_ammo_UI_effects(event_origin)
		var txt_node:	Object = add_ammo_UI_text(event_origin)
		#add_font_effects(txt_node)
		signal_free_shot_begin()
		var ammo_tween:Tween = fx_node.get_child(0)
		var ammo_success:bool = ammo_tween.start()
		if !ammo_success:
			print("ammo tween failed")
			return
		var text_tween:Tween = txt_node.get_child(0)
		var text_success = text_tween.start()
		if !text_success:
			print("text tween failed")
			return
		#wait for the ammo UI to get into place
		yield(ammo_tween, "tween_completed")
		yield(ammo_tween, "tween_completed")
		yield(text_tween, "tween_completed")
		var animate_success:bool = animate_text_removal(txt_node.get_child(1), text_tween)
		if !animate_success:
			return
		var text_success_2:bool = text_tween.start()
		if !text_success_2:
			print("text tween 2 failed")
			return
		fx_node.queue_free()
		signal_free_shot_end()
		yield(text_tween, "tween_completed")
		txt_node.queue_free()

func add_ammo_UI_effects(event_origin) -> Object:
	var parent_container:	Object	= self.get_node_or_null("ammo")
	var ammo_instance:		Object 	= parent_container.get_resource_instance()
	var tween:				Tween 	= add_child_tween(ammo_instance)
	ammo_instance.rotate(parent_container.get("rotation"))
	self.add_child(ammo_instance)

	var start_pos:	Vector2	= event_origin.get("global_position")
	var end_pos:	Vector2	= parent_container.get_global_node_pos()
	var pos_tween:bool = tween_property(start_pos, end_pos, ammo_instance, "position", tween, 2.0)
	if !pos_tween:
		return null

	var start_scale:Vector2	= Vector2(0,0)
	var end_scale:	Vector2	= parent_container.get("scale")
	var scale_tween:bool = tween_property(start_scale, end_scale, ammo_instance, "scale", tween, 2.0)
	if !scale_tween:
		return null
	return ammo_instance

func add_ammo_UI_text(event_origin:Object) -> Object:
	var text:		String 	= "Free Ball!"
	var rand_color:	Color 	= get_rand_color()
	var text_box:	Object 	= self.get("label_template").instance()
	text_box.modulate = rand_color
	self.get("randomize_modulates").append(text_box)
	text_box.text = text
	var spawn_point:Vector2 = event_origin.get_parent().get_parent().get("global_position")
	spawn_point = spawn_point + free_ball_text_offset
	var parent:		Object = Node2D.new()
	parent.global_position = spawn_point
	var tween:		Tween = add_child_tween(parent)	#must be first child
	parent.add_child(text_box)
	self.add_child(parent)
	var tween_success:bool = tween_property(free_ball_text_scale, free_ball_text_scale2,
	text_box, "rect_scale", tween, 2.0,
	Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	if tween_success:
		return parent
	else:
		return null

func animate_text_removal(text:Object, tween:Tween, time:float = 1.0) -> bool:
	return tween_property(1.0, 0.0, text, "percent_visible", tween,
		time, Tween.TRANS_LINEAR)

func add_child_tween(parent) -> Object:
	if is_instance_valid(parent):
		var tween:Object = Tween.new()
		parent.add_child(tween)
		return tween
	else:
		return null

func get_rand_color() -> Color:
	var color_arr: 	Array = self.get("colors")
	var idx_range:	int = color_arr.size()
	var index:		int = randi() % idx_range
	return color_arr[index]

func make_node2D_child(pos:Vector2, obj:Object) -> Object:
	var node:Object = Node2D.new()
	self.add_child(node)
	node.global_position = pos
	node.add_child(obj)
	return node

func signal_free_shot_begin() -> void:
	emit_signal("UI_signal", "prevent_firing")

func signal_free_shot_end() -> void:
	emit_signal("UI_signal", "increase_ammo")
	emit_signal("UI_signal", "allow_firing")

func _on_Tween_tween_completed(object: Object, _key: NodePath) -> void:
	var repeat_obj:bool = !(is_unique(object))
	if repeat_obj:
		return
	else:
		self.get("tweened_objs").append(object)
		if object.is_in_group("tween_event_despawn"):
			object.queue_free()

func is_unique(obj:Object, arr:Array = self.get("tweened_objs")) -> bool:
	for elem in arr:
		var valid_element:bool = is_instance_valid(elem)
		if (valid_element and (elem == obj)):
			return false
	return true

func draw_text(pos:Vector2, message:String = "sample text") -> void:
	var node:Object = Node2D.new()
	self.add_child(node)
	node.global_position = pos
	var text_box:Object = self.get("label_template").instance()
	text_box.text = message
	node.add_child(text_box)

func draw_obj(pos:Vector2, obj:Resource = self.get("label_template")) -> void:
	var node:Object = Node2D.new()
	self.add_child(node)
	node.global_position = pos
	node.add_child(obj)

var colors = [
Color( 0.94, 0.97, 1, 1 ), # Alice blue color.
Color( 0.98, 0.92, 0.84, 1 ), # Antique white color.
Color( 0, 1, 1, 1 ), # Aqua color.
Color( 0.5, 1, 0.83, 1 ), # Aquamarine color.
Color( 0.94, 1, 1, 1 ), # Azure color.
Color( 0.96, 0.96, 0.86, 1 ), # Beige color.
Color( 1, 0.89, 0.77, 1 ), # Bisque color.
Color( 0, 0, 0, 1 ), # Black color.
Color( 1, 0.92, 0.8, 1 ), # Blanche almond color.
Color( 0, 0, 1, 1 ), # Blue color.
Color( 0.54, 0.17, 0.89, 1 ), # Blue violet color.
Color( 0.65, 0.16, 0.16, 1 ), # Brown color.
Color( 0.87, 0.72, 0.53, 1 ), # Burly wood color.
Color( 0.37, 0.62, 0.63, 1 ), # Cadet blue color.
Color( 0.5, 1, 0, 1 ), # Chartreuse color.
Color( 0.82, 0.41, 0.12, 1 ), # Chocolate color.
Color( 1, 0.5, 0.31, 1 ), # Coral color.
Color( 0.39, 0.58, 0.93, 1 ), # Cornflower color.
Color( 1, 0.97, 0.86, 1 ), # Corn silk color.
Color( 0.86, 0.08, 0.24, 1 ), # Crimson color.
Color( 0, 1, 1, 1 ), # Cyan color.
Color( 0, 0, 0.55, 1 ), # Dark blue color.
Color( 0, 0.55, 0.55, 1 ), # Dark cyan color.
Color( 0.72, 0.53, 0.04, 1 ), # Dark goldenrod color.
Color( 0.66, 0.66, 0.66, 1 ), # Dark gray color.
Color( 0, 0.39, 0, 1 ), # Dark green color.
Color( 0.74, 0.72, 0.42, 1 ), # Dark khaki color.
Color( 0.55, 0, 0.55, 1 ), # Dark magenta color.
Color( 0.33, 0.42, 0.18, 1 ), # Dark olive green color.
Color( 1, 0.55, 0, 1 ), # Dark orange color.
Color( 0.6, 0.2, 0.8, 1 ), # Dark orchid color.
Color( 0.55, 0, 0, 1 ), # Dark red color.
Color( 0.91, 0.59, 0.48, 1 ), # Dark salmon color.
Color( 0.56, 0.74, 0.56, 1 ), # Dark sea green color.
Color( 0.28, 0.24, 0.55, 1 ), # Dark slate blue color.
Color( 0.18, 0.31, 0.31, 1 ), # Dark slate gray color.
Color( 0, 0.81, 0.82, 1 ), # Dark turquoise color.
Color( 0.58, 0, 0.83, 1 ), # Dark violet color.
Color( 1, 0.08, 0.58, 1 ), # Deep pink color.
Color( 0, 0.75, 1, 1 ), # Deep sky blue color.
Color( 0.41, 0.41, 0.41, 1 ), # Dim gray color.
Color( 0.12, 0.56, 1, 1 ), # Dodger blue color.
Color( 0.7, 0.13, 0.13, 1 ), # Firebrick color.
Color( 1, 0.98, 0.94, 1 ), # Floral white color.
Color( 0.13, 0.55, 0.13, 1 ), # Forest green color.
Color( 1, 0, 1, 1 ), # Fuchsia color.
Color( 0.86, 0.86, 0.86, 1 ), # Gainsboro color.
Color( 0.97, 0.97, 1, 1 ), # Ghost white color.
Color( 1, 0.84, 0, 1 ), # Gold color.
Color( 0.85, 0.65, 0.13, 1 ), # Goldenrod color.
Color( 0.75, 0.75, 0.75, 1 ), # Gray color.
Color( 0, 1, 0, 1 ), # Green color.
Color( 0.68, 1, 0.18, 1 ), # Green yellow color.
Color( 0.94, 1, 0.94, 1 ), # Honeydew color.
Color( 1, 0.41, 0.71, 1 ), # Hot pink color.
Color( 0.8, 0.36, 0.36, 1 ), # Indian red color.
Color( 0.29, 0, 0.51, 1 ), # Indigo color.
Color( 1, 1, 0.94, 1 ), # Ivory color.
Color( 0.94, 0.9, 0.55, 1 ), # Khaki color.
Color( 0.9, 0.9, 0.98, 1 ), # Lavender color.
Color( 1, 0.94, 0.96, 1 ), # Lavender blush color.
Color( 0.49, 0.99, 0, 1 ), # Lawn green color.
Color( 1, 0.98, 0.8, 1 ), # Lemon chiffon color.
Color( 0.68, 0.85, 0.9, 1 ), # Light blue color.
Color( 0.94, 0.5, 0.5, 1 ), # Light coral color.
Color( 0.88, 1, 1, 1 ), # Light cyan color.
Color( 0.98, 0.98, 0.82, 1 ), # Light goldenrod color.
Color( 0.83, 0.83, 0.83, 1 ), # Light gray color.
Color( 0.56, 0.93, 0.56, 1 ), # Light green color.
Color( 1, 0.71, 0.76, 1 ), # Light pink color.
Color( 1, 0.63, 0.48, 1 ), # Light salmon color.
Color( 0.13, 0.7, 0.67, 1 ), # Light sea green color.
Color( 0.53, 0.81, 0.98, 1 ), # Light sky blue color.
Color( 0.47, 0.53, 0.6, 1 ), # Light slate gray color.
Color( 0.69, 0.77, 0.87, 1 ), # Light steel blue color.
Color( 1, 1, 0.88, 1 ), # Light yellow color.
Color( 0, 1, 0, 1 ), # Lime color.
Color( 0.2, 0.8, 0.2, 1 ), # Lime green color.
Color( 0.98, 0.94, 0.9, 1 ), # Linen color.
Color( 1, 0, 1, 1 ), # Magenta color.
Color( 0.69, 0.19, 0.38, 1 ), # Maroon color.
Color( 0.4, 0.8, 0.67, 1 ), # Medium aquamarine color.
Color( 0, 0, 0.8, 1 ), # Medium blue color.
Color( 0.73, 0.33, 0.83, 1 ), # Medium orchid color.
Color( 0.58, 0.44, 0.86, 1 ), # Medium purple color.
Color( 0.24, 0.7, 0.44, 1 ), # Medium sea green color.
Color( 0.48, 0.41, 0.93, 1 ), # Medium slate blue color.
Color( 0, 0.98, 0.6, 1 ), # Medium spring green color.
Color( 0.28, 0.82, 0.8, 1 ), # Medium turquoise color.
Color( 0.78, 0.08, 0.52, 1 ), # Medium violet red color.
Color( 0.1, 0.1, 0.44, 1 ), # Midnight blue color.
Color( 0.96, 1, 0.98, 1 ), # Mint cream color.
Color( 1, 0.89, 0.88, 1 ), # Misty rose color.
Color( 1, 0.89, 0.71, 1 ), # Moccasin color.
Color( 1, 0.87, 0.68, 1 ), # Navajo white color.
Color( 0, 0, 0.5, 1 ), # Navy blue color.
Color( 0.99, 0.96, 0.9, 1 ), # Old lace color.
Color( 0.5, 0.5, 0, 1 ), # Olive color.
Color( 0.42, 0.56, 0.14, 1 ), # Olive drab color.
Color( 1, 0.65, 0, 1 ), # Orange color.
Color( 1, 0.27, 0, 1 ), # Orange red color.
Color( 0.85, 0.44, 0.84, 1 ), # Orchid color.
Color( 0.93, 0.91, 0.67, 1 ), # Pale goldenrod color.
Color( 0.6, 0.98, 0.6, 1 ), # Pale green color.
Color( 0.69, 0.93, 0.93, 1 ), # Pale turquoise color.
Color( 0.86, 0.44, 0.58, 1 ), # Pale violet red color.
Color( 1, 0.94, 0.84, 1 ), # Papaya whip color.
Color( 1, 0.85, 0.73, 1 ), # Peach puff color.
Color( 0.8, 0.52, 0.25, 1 ), # Peru color.
Color( 1, 0.75, 0.8, 1 ), # Pink color.
Color( 0.87, 0.63, 0.87, 1 ), # Plum color.
Color( 0.69, 0.88, 0.9, 1 ), # Powder blue color.
Color( 0.63, 0.13, 0.94, 1 ), # Purple color.
Color( 0.4, 0.2, 0.6, 1 ), # Rebecca purple color.
Color( 1, 0, 0, 1 ), # Red color.
Color( 0.74, 0.56, 0.56, 1 ), # Rosy brown color.
Color( 0.25, 0.41, 0.88, 1 ), # Royal blue color.
Color( 0.55, 0.27, 0.07, 1 ), # Saddle brown color.
Color( 0.98, 0.5, 0.45, 1 ), # Salmon color.
Color( 0.96, 0.64, 0.38, 1 ), # Sandy brown color.
Color( 0.18, 0.55, 0.34, 1 ), # Sea green color.
Color( 1, 0.96, 0.93, 1 ), # Seashell color.
Color( 0.63, 0.32, 0.18, 1 ), # Sienna color.
Color( 0.75, 0.75, 0.75, 1 ), # Silver color.
Color( 0.53, 0.81, 0.92, 1 ), # Sky blue color.
Color( 0.42, 0.35, 0.8, 1 ), # Slate blue color.
Color( 0.44, 0.5, 0.56, 1 ), # Slate gray color.
Color( 1, 0.98, 0.98, 1 ), # Snow color.
Color( 0, 1, 0.5, 1 ), # Spring green color.
Color( 0.27, 0.51, 0.71, 1 ), # Steel blue color.
Color( 0.82, 0.71, 0.55, 1 ), # Tan color.
Color( 0, 0.5, 0.5, 1 ), # Teal color.
Color( 0.85, 0.75, 0.85, 1 ), # Thistle color.
Color( 1, 0.39, 0.28, 1 ), # Tomato color.
Color( 1, 1, 1, 0 ), # Transparent color (white with no alpha).
Color( 0.25, 0.88, 0.82, 1 ), # Turquoise color.
Color( 0.93, 0.51, 0.93, 1 ), # Violet color.
Color( 0.5, 0.5, 0.5, 1 ), # Web gray color.
Color( 0, 0.5, 0, 1 ), # Web green color.
Color( 0.5, 0, 0, 1 ), # Web maroon color.
Color( 0.5, 0, 0.5, 1 ), # Web purple color.
Color( 0.96, 0.87, 0.7, 1 ), # Wheat color.
Color( 1, 1, 1, 1 ), # White color.
Color( 0.96, 0.96, 0.96, 1 ), # White smoke color.
Color( 1, 1, 0, 1 ), # Yellow color.
Color( 0.6, 0.8, 0.2, 1 ), # Yellow green color.
]
