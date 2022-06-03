extends KinematicBody2D
var color
var color_on_hit
export(Color) var default_color
export(Color) var default_color_on_hit
export(Color) var special_color
export(Color) var special_color_on_hit
var curr_col = color
var curr_col_on_hit = color_on_hit
var shot_collision_count = 0
var max_collision_count	 = 5
var peg_type setget set_peg_type
var level
var counter = 0

signal peg_collision(peg, behavior)

func get_peg_color():
	var has_been_hit:bool = (self.get("shot_collision_count") != 0)
	var new_color:Color
	if has_been_hit:
		new_color 		  = self.get("color_on_hit")
	else:
		new_color 		  = self.get("color")
	return new_color

func set_peg_type(new_type):
	peg_type = new_type
	type_update_colors()
	type_update_sprite()
	type_update_light()

func type_update_colors():
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

func type_update_sprite():
	var new_color = get_peg_color()
	var peg_sprite 		  = self.get_node_or_null("sprite")
	var valid_sprite:bool = is_instance_valid(peg_sprite)
	if valid_sprite:
		$sprite.set_colors(new_color)
		$sprite.update_colors()

func type_update_light():
	var new_color = get_peg_color()
	var peg_light  		  = self.get_node_or_null("Light2D")
	var valid_light:bool  = is_instance_valid(peg_light)
	if valid_light:
		$Light2D.set("color", new_color)

func _ready():
	add_to_group("pegs")
	self.set("peg_type", "default")
	initialize_light()

func initialize_light():
	var light 			 = self.get_node_or_null("Light2D")
	var valid_light:bool = is_instance_valid(light)
	if valid_light:
		$Light2D.energy_floor = 0.75
		$Light2D.base_energy = 2.0

func collide():
	var collision_count = increment_collision_count()

	emit_signal("peg_collision", self, "queue despawn")
	any_collision_update()

	var max_collisions 	= self.get("max_collision_count")
	var collisions_maxed:bool = (collision_count > max_collisions)
	if collisions_maxed:
		on_collisions_maxed()

	var first_collision:bool  = (collision_count == 1)
	if first_collision:
		on_first_collision()

func increment_collision_count():
	var new_count = self.get("shot_collision_count") + 1
	self.set("shot_collision_count", new_count)
	return new_count

func on_collisions_maxed():
	despawn_peg()

func despawn_peg():
	emit_signal("peg_collision", self, "despawn")

func on_first_collision():
	one_shot_update()

func one_shot_update():
	one_shot_sprite_fx()
	one_shot_light_fx()

func one_shot_sprite_fx():
	var hit_color:Color 	 = self.get("color_on_hit")
	var peg_sprite 			  = self.get_node_or_null("sprite")
	var valid_peg_sprite:bool = is_instance_valid(peg_sprite)
	if valid_peg_sprite:
		$sprite.set_colors(hit_color)
		$sprite.update_colors()

func one_shot_light_fx():
	var hit_color:Color 	 = self.get("color_on_hit")
	var peg_light 			 = self.get_node_or_null("Light2D")
	var valid_peg_light:bool = is_instance_valid(peg_light)
	if valid_peg_light:
		$Light2D.set("color", hit_color)

func any_collision_update():
	any_collision_sprite_fx()
	any_collision_light_fx()

func any_collision_sprite_fx():
	var sprite 			  = self.get_node_or_null("sprite")
	var valid_sprite:bool = is_instance_valid(sprite)
	if valid_sprite:
		$sprite.darken_colors(0.1)

func any_collision_light_fx():
	var light 			 = self.get_node_or_null("Light2D")
	var valid_light:bool = is_instance_valid(light)
	if valid_light:
		$Light2D.add_energy()
		$Light2D.time_scale = 0.6
		$Light2D.twinkle_floor = 1.0

#$sprite.increase_colors_transparency()
#$sprite.darken_colors()
#$sprite.greyscale_colors()
#$sprite.invert_colors()
#$sprite.invert_colors(true, false)
#center = center.blend(Color.green)
#border = border.blend(Color.red)
