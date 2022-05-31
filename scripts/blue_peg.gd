extends KinematicBody2D
export(Color) var color_on_hit
var shot_collision_count = 0
var max_collision_count	 = 5
var color_changed:	bool = false
var level
var counter = 0

signal peg_collision(peg, behavior)
#signal peg_collision_timeout(peg)

func _ready():
	add_to_group("pegs")
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
		light.color = color_on_hit

#func initialize_collision_timer(time):
#	var timer = Timer.new()
#	timer.connect("timeout", self, "despawn_peg")
#	self.add_child(timer)
#	timer.start(5)

func despawn_peg():
	emit_signal("peg_collision", self, "despawn")

func change_colors_one_shot():
	#$sprite.increase_colors_transparency()
	#$sprite.darken_colors()
	#$sprite.greyscale_colors()
	#$sprite.invert_colors()
	$sprite.set_colors(color_on_hit)
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


