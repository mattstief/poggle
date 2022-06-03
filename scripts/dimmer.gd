extends Light2D
var initial_light_time:	float = 0.8
var running_light_time:	float = 0.0
var twinkle_floor:		float = 0.0	#only used for tween
var energy_floor:		float = 0.0
var base_energy:	   	float = 1.0
var time_scale:			float = 1.0

var dim_over_time:bool = true
var twinkle:	  bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var tween = Tween.new()
	self.add_child(tween)
	pass # Replace with function body.

func _process(delta: float) -> void:
	count_down(delta)
	if self.get("twinkle"):
		twinkle_cycle()
	else:
		self.set("energy", energy_floor)

	if self.get("dim_over_time"):
		dim_light()

func count_down(delta) -> void:
	var light_timer = self.get("running_light_time")
	if (light_timer > 0):
		var multiplier  = self.get("time_scale")
		var count_down_amnt = (delta * multiplier)
		light_timer = light_timer - count_down_amnt
		self.set("running_light_time", light_timer)

func dim_light() -> void:
	var curr_time:	float  = self.get("running_light_time")
	var dimmable:	bool   = (curr_time > 0)
	if dimmable:
		var energy_val = get_energy_at_t(curr_time)
		self.set("energy", energy_val)

func add_energy(val = initial_light_time) -> void:
	var new_value = self.get("running_light_time")
	new_value = new_value + val
	self.set("running_light_time", new_value)

func get_energy_at_t(time:float = running_light_time) -> float:
	var starting_time:float = self.get("initial_light_time")
	var multiplier:   float = self.get("base_energy")
	var floor_val:	  float	= self.get("energy_floor")
	var time_ratio:	  float	= time/starting_time
	var result_energy:float = time_ratio * multiplier
	if (result_energy < floor_val):
		return floor_val
	else:
		return result_energy

func twinkle_cycle() -> void:
	var tween = self.get_child(0)
	var can_tween:bool = (is_instance_valid(tween) and !(tween.is_active()))
	if can_tween:
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
			self.get("energy"),
			val,
			0.7,
			Tween.TRANS_SINE,
			Tween.EASE_IN_OUT
		)
		tween.start()
