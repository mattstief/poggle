extends Node2D
var alpha_factor_on_hit 	= 0.1
var default_lighten_value	= 0.3
var default_darken_value	= 0.3
export(float) var special_probability = 0.3

# Called when the node enters the scene tree for the first time.
func _ready():
	count_total_pegs()
	pass # Replace with function body.

func count_total_pegs():
	var all_pegs = get_tree().get_nodes_in_group("pegs")
	var total_peg_count = all_pegs.size()
	var special_count:int = float(total_peg_count) * special_probability
	var rand_arr:Array = []
	randomize()
	for i in special_count:
		var rand_not_found:bool = true
		var rand_num
		while (rand_not_found):
			rand_num = (randi() % total_peg_count)
			rand_not_found = is_in_arr(rand_num, rand_arr)
		rand_arr.append(rand_num)
	verify_unique(rand_arr)
	for idx in range(rand_arr.size()):
		all_pegs[rand_arr[idx]].set("peg_type", "special")

func verify_unique(arr):
	var sz = arr.size()
	for i in range(sz):
		for j in range(sz):
			if (i == j):
				continue
			elif arr[i] == arr[j]:
				print("not unique! (", i, ", ", j, ")")

func is_in_arr(val, arr):
	var sz = arr.size()
	for i in sz:
		if ((arr[i] - val) == 0):
			return true
	return false

func randomize_pegs():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
