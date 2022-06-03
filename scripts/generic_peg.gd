extends KinematicBody2D
var color:		 Color
var color_on_hit:Color
export(Color) var default_color:		Color
export(Color) var default_color_on_hit:	Color
export(Color) var special_color:		Color
export(Color) var special_color_on_hit:	Color
var shot_collision_count:int = 0
var max_collision_count: int = 5
var peg_type:String setget set_peg_type

signal peg_collision(peg, behavior)

func get_peg_color() -> Color:
	var new_color:Color
	var has_been_hit:bool = (self.get("shot_collision_count") != 0)
	if has_been_hit:
		new_color = self.get("color_on_hit")
	else:
		new_color = self.get("color")
	return new_color

func set_peg_type(new_type) -> void:
	peg_type = new_type
	type_update_colors()
	type_update_sprite()
	type_update_light()

func type_update_colors() -> void:
	var new_type = self.get("peg_type")
	var new_color	 :Color
	var new_hit_color:Color

	if (new_type == "special"):
		new_color 		= self.get("special_color")
		new_hit_color   = self.get("special_color_on_hit")

	elif (new_type == "default"):
		new_color 		= self.get("default_color")
		new_hit_color   = self.get("default_color_on_hit")

	self.set("color", new_color)
	self.set("color_on_hit", new_hit_color)

func type_update_sprite() -> void:
	var new_color:Color 	= get_peg_color()
	var circle:Node2D		= self.get_node_or_null("bordered_circle")
	var valid_circle:bool	= is_instance_valid(circle)
	if valid_circle:
		circle.set_colors(new_color)
		circle.update_colors()

func type_update_light() -> void:
	var new_color:Color 	 = get_peg_color()
	var peg_light:Light2D  	 = self.get_node_or_null("Light2D")
	var valid_peg_light:bool = is_instance_valid(peg_light)
	if valid_peg_light:
		peg_light.set("color", new_color)

func _ready() -> void:
	add_to_group("pegs")
	self.set("peg_type", "default")
	initialize_light()

func initialize_light() -> void:
	var peg_light:Light2D	 = self.get_node_or_null("Light2D")
	var valid_peg_light:bool = is_instance_valid(peg_light)
	if valid_peg_light:
		peg_light.energy_floor = 0.75
		peg_light.base_energy = 2.0

func collide() -> void:
	var collision_count:int = increment_collision_count()

	emit_signal("peg_collision", self, "queue despawn")
	any_collision_update()

	var max_collisions:  int  = self.get("max_collision_count")
	var collisions_maxed:bool = (collision_count > max_collisions)
	if collisions_maxed:
		on_collisions_maxed()

	var first_collision:bool  = (collision_count == 1)
	if first_collision:
		on_first_collision()

func increment_collision_count() -> int:
	var new_count:int = self.get("shot_collision_count") + 1
	self.set("shot_collision_count", new_count)
	return new_count

func on_collisions_maxed() -> void:
	despawn_peg()

func despawn_peg() -> void:
	emit_signal("peg_collision", self, "despawn")

func on_first_collision() -> void:
	one_shot_update()

func one_shot_update() -> void:
	one_shot_sprite_fx()
	one_shot_light_fx()

func one_shot_sprite_fx() -> void:
	var hit_color:Color		= self.get("color_on_hit")
	var circle:Node2D		= self.get_node_or_null("bordered_circle")
	var valid_circle:bool	= is_instance_valid(circle)
	if valid_circle:
		circle.set_colors(hit_color)
		circle.update_colors()

func one_shot_light_fx() -> void:
	var hit_color:Color 	 	= self.get("color_on_hit")
	var peg_light:Light2D 		= self.get_node_or_null("Light2D")
	var valid_peg_light:bool 	= is_instance_valid(peg_light)
	if valid_peg_light:
		peg_light.set("color", hit_color)

func any_collision_update() -> void:
	any_collision_sprite_fx()
	any_collision_light_fx()

func any_collision_sprite_fx() -> void:
	var circle:Node2D 	  = self.get_node_or_null("bordered_circle")
	var valid_circle:bool = is_instance_valid(circle)
	if valid_circle:
		circle.darken_colors(0.1)

func any_collision_light_fx() -> void:
	var peg_light:Light2D 	 = self.get_node_or_null("Light2D")
	var valid_peg_light:bool = is_instance_valid(peg_light)
	if valid_peg_light:
		peg_light.add_energy()
		peg_light.time_scale = 0.6
		peg_light.twinkle_floor = 1.0

#$sprite.increase_colors_transparency()
#$sprite.darken_colors()
#$sprite.greyscale_colors()
#$sprite.invert_colors()
#$sprite.invert_colors(true, false)
#center = center.blend(Color.green)
#border = border.blend(Color.red)
