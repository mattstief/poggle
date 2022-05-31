extends Light2D
var initial_light_time = 0.8
var running_light_time = 0
var base_energy = 1.0
var energy_floor = 0.0
var twinkle_floor = 0.0
var dim_scale = 1.0
var dim_over_time:bool = true

var twinkle:bool 	   = true
var alternator 		   = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var tween = Tween.new()
	self.add_child(tween)
	pass # Replace with function body.

func _process(delta: float) -> void:
	if twinkle:
		twinkle_cycle()
	else:
		energy = energy_floor
	if dim_over_time:
		dim_light(delta)


func dim_light(delta):
	var light_timer = self.get("running_light_time")
	var dim_multiplier = self.get("dim_scale")
	if (light_timer > 0):
		light_timer = light_timer - (delta * dim_multiplier)
		self.set("running_light_time", light_timer)
		self.set("energy", get_light_modifier(light_timer))

func add_energy(val = initial_light_time):
	var new_value = self.get("running_light_time")
	new_value = new_value + val
	self.set("running_light_time", new_value)

func get_light_modifier(time = running_light_time):
	var starting_time:float = self.get("initial_light_time")
	var multiplier:float = self.get("base_energy")
	var ending_energy:float	= self.get("energy_floor")
	var ratio = float(time)/starting_time
	var value = ratio * multiplier
	if (value < ending_energy):
		return ending_energy
	else:
		return ratio * multiplier

func twinkle_cycle():
	var tween = self.get_child(0)
	if (tween and !(tween.is_active())):
		var rand = RandomNumberGenerator.new()
		rand.randomize()
		var rand_variation = rand.randi()
		var val
		if (rand_variation < 1000000):
			val = rand.randf_range(2.0, 3.4)
		elif (rand_variation < 2000000000):
			val = twinkle_floor
		else:
			val = rand.randf_range(0.8, 1.6)
		tween.interpolate_property(
		self,
		"energy",
		energy,
		val,
		0.7,
		Tween.TRANS_SINE,
		Tween.EASE_IN_OUT)
		tween.start()
