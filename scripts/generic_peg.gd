extends KinematicBody2D
export(Color) var color
export(Color) var color_on_hit
export(Color) var special_color
export(Color) var special_color_on_hit
var curr_col = color
var curr_col_on_hit = color_on_hit
var shot_collision_count = 0
var max_collision_count	 = 5
var color_changed:	bool = false
var peg_type setget set_peg_type
var level
var counter = 0

func set_peg_type(new_type):
	peg_type = new_type
	if new_type == "special":
		$sprite.set_colors(special_color)
		curr_col = special_color
		curr_col_on_hit = special_color_on_hit
	elif new_type == "default":
		$sprite.set_colors(color)
		curr_col = color
		curr_col_on_hit = color_on_hit
	$sprite.update_colors()
	self.get_node_or_null("Light2D").set("color", curr_col)


signal peg_collision(peg, behavior)
#signal peg_collision_timeout(peg)

func _ready():
	add_to_group("pegs")
	self.peg_type = "default"
	var light = self.get_node_or_null("Light2D")
	if light:
		light.energy_floor = 0.75
		light.base_energy = 2.0

func collide():
	self.set("shot_collision_count", shot_collision_count + 1)
	emit_signal("peg_collision", self, "queue despawn")
	var first_collision:bool = (shot_collision_count == 1)
	if first_collision:
		change_colors_one_shot()
		color_changed = true
	change_colors_invariant()
	if (shot_collision_count > max_collision_count):
		despawn_peg()
	var light = self.get_node_or_null("Light2D")
	if light:
		light.add_energy()
		light.dim_scale = 0.6
		light.twinkle_floor = 1.0
		light.color = curr_col

func despawn_peg():
	emit_signal("peg_collision", self, "despawn")

func change_colors_one_shot():
	#$sprite.increase_colors_transparency()
	#$sprite.darken_colors()
	#$sprite.greyscale_colors()
	#$sprite.invert_colors()
	$sprite.set_colors(curr_col_on_hit)
	#$sprite.invert_colors(true, false)
	#center = center.blend(Color.green)
	#border = border.blend(Color.red)
	pass

func change_colors_invariant():
	#$sprite.lighten_colors(0.1)
	$sprite.darken_colors(0.1)
	#$sprite.increase_colors_transparency(0.8)
	#$sprite.lighten_colors(0.1, true, false)
	##$sprite.darken_colors()
	#$sprite.greyscale_colors()
	#$sprite.invert_colors()
	#$sprite.invert_colors(true, false)
	#$sprite.lighten_colors(.01)
	#center = center.blend(Color.green)
	#border = border.blend(Color.red)
	pass


