extends Node2D
var alpha_factor_on_hit 	= 0.1
var default_lighten_value	= 0.3
var default_darken_value	= 0.3
export(float) var special_probability = 0.3

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize_pegs()

func randomize_pegs():
	var all_pegs = get_tree().get_nodes_in_group("pegs")
	var total_peg_count = all_pegs.size()
	var special_count:int = float(total_peg_count) * special_probability
	set_special_pegs(all_pegs, total_peg_count, special_count)

func set_special_pegs(peg_list, peg_count, special_count):
	var special_indexes:Array = get_unique_rand_arr(special_count, peg_count)
	for idx in special_indexes:
		peg_list[idx].set("peg_type", "special")

func get_unique_rand_arr(rand_count, num_range):
	var rand_arr:Array = []
	randomize()
	for i in rand_count:
		var rand_not_found:bool = true
		var rand_num
		while (rand_not_found):
			rand_num = (randi() % num_range)
			rand_not_found = is_in_arr(rand_num, rand_arr)
		rand_arr.append(rand_num)
	return rand_arr

func is_in_arr(val, arr):
	var sz = arr.size()
	for i in sz:
		if ((arr[i] - val) == 0):
			return true
	return false

#DEBUG
func verify_unique(arr):
	var sz = arr.size()
	for i in range(sz):
		for j in range(sz):
			if (i == j):
				continue
			elif arr[i] == arr[j]:
				print("not unique! (", i, ", ", j, ")")
