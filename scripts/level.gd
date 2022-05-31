extends Node2D
export(float) var shot_speed		= 1100
export(float) var shot_gravity 		= 1200
export(float) var shot_bounciness  	= 1
var shots_remaining = 20 setget set_shots_remaining
var shots_on_screen = 0
var pegs_remaining  = 0
var despawn_queue:Array
var firing_blocked:bool = false

func print_connect_err(failed_signal:String, err):
	print("error connecting ", failed_signal, err)

func initialize_pegs():
	var peg_collection = get_tree().get_nodes_in_group("pegs")
	var starting_peg_count = peg_collection.size()
	set("pegs_remaining", starting_peg_count)
	for peg in peg_collection:
		var peg_err = peg.connect("peg_collision", self, "_on_peg_collision")
		if peg_err:
			print_connect_err("peg_err", peg_err)

func initialize_gun():
	var barrel = get_node_or_null("gun/barrel")
	var barrel_exists:bool = is_instance_valid(barrel)
	if barrel_exists:
		var shoot_err  = barrel.connect("shoot_input", self, "_on_shoot_input")
		var sprite_err = barrel.connect("spawn_obj", self, "_on_spawn_obj")
		if shoot_err:
			print_connect_err("shoot_err", shoot_err)
		if sprite_err:
			print_connect_err("sprite_err", sprite_err)
	else:
		print("no gun?! exiting")
		get_tree().quit()

func initialize_bucket():
	var catcher = get_node_or_null("catcher_body/catcher")
	var catcher_exists:bool = is_instance_valid(catcher)
	if catcher_exists:
		var catch_err = catcher.connect("projectile_caught", self, "_on_catch")
		if catch_err:
			print_connect_err("catch_err", catch_err)
	else:
		print("no catcher")

func initialize_UI():
	var UI = get_node_or_null("UI")
	var UI_exists:bool = is_instance_valid(UI)
	if UI_exists:
		var UI_err = UI.connect("UI_signal", self, "_on_UI_signal")
		if UI_err:
			print_connect_err("UI_err", UI_err)
	else:
		print("no UI in scene!")
		get_tree().quit()
	update_ammo_UI()

# Called when the node enters the scene tree for the first time.
func _ready():
	var vp = get_node_or_null("root/viewport")
	if vp != null:
		print("viewport_rect: ", vp.get_visible_rect())
	initialize_pegs()
	initialize_gun()
	initialize_bucket()
	initialize_UI()

func _on_spawn_obj(obj):
	self.add_child(obj)

func _on_shoot_input(asset, rot, pos):
	var shot_allowed:bool = can_spawn_projectile()
	if shot_allowed:
		var success = spawn_projectile(asset, rot, pos)
		if success:
			begin_shot()

func _on_peg_collision(peg, behavior:String):
	if behavior == "queue despawn":
		get("despawn_queue").append(peg)
	elif behavior == "despawn":
		despawn(peg)
	else:
		pass

func _on_catch(catcher):
	print("caught!")
	self.catch_event(catcher.get("action"))
	$UI.draw_event(catcher.get("action"), catcher)

func _on_UI_signal(arg):
	if arg == "increase_ammo":
		var new_remainder = self.get("shots_remaining") + 1
		self.set("shots_remaining", new_remainder)
	if arg == "prevent_firing":
		self.set("firing_blocked", true)
	if arg == "allow_firing":
		self.set("firing_blocked", false)

func catch_event(arg = "default"):
	if (arg == "free ball"):
		pass

func can_spawn_projectile():
	if self.get("firing_blocked"):
		return false
	var shot_ammo = self.get("shots_remaining")
	var shots_out = self.get("shots_on_screen")
	var existing_projectile:bool = (shots_out > 0)
	var out_of_shots:		bool = (shot_ammo < 1)
	if (existing_projectile or out_of_shots):
		return false
	else:
		return true

func spawn_projectile(asset, rot, pos):
	var bullet = asset.instance()
	if is_instance_valid(bullet):
		bullet.connect("projectile_despawn", self, "_on_projectile_despawn")
		bullet.set("bounciness",self.get("shot_bounciness"))
		bullet.set("gravity"   ,self.get("shot_gravity"))
		bullet.set("speed"	   ,self.get("shot_speed"))
		bullet.set("rotation", rot)
		bullet.set("position", pos)
		self.add_child(bullet)
		return 1
	else:
		return 0

func set_shots_remaining(new_remainder = shots_remaining):
	shots_remaining = new_remainder
	update_ammo_UI()

func update_ammo_UI(count = shots_remaining):
	if is_instance_valid($UI/ammo):
		$UI/ammo.set_node_count(count)

func begin_shot():
	var on_screen = self.get("shots_on_screen") + 1
	var remaining = self.get("shots_remaining") - 1
	self.set("shots_on_screen", on_screen)
	self.set("shots_remaining", remaining)

#called when a shot is no longer bouncing about
func _on_projectile_despawn():
	remove_pegs()
	expend_shot()

func remove_pegs():
	var arr = self.get("despawn_queue")
	var peg_count = 0
	for obj in arr:
		if is_peg(obj):
			peg_count = peg_count + 1
	var pegs_left = (self.get("pegs_remaining") - peg_count)
	set("pegs_remaining", pegs_left)
	flush_arr(arr)

func expend_shot():
	var old_shots_out	= self.get("shots_on_screen")
	var curr_shots_out	= (old_shots_out - 1)
	set("shots_on_screen", curr_shots_out)

#despawns all elements in the arr and clears it
func flush_arr(arr):
	for obj in arr:
		var success = despawn(obj)
		if success:
			yield(get_tree().create_timer(0.1), "timeout")
	arr.clear()

func is_peg(obj):
	var valid_obj:bool = is_instance_valid(obj)
	if valid_obj:
		return (obj.is_in_group("pegs"))
	else:
		return false

#despawns instance, returns 1 on success or 0 on fail
func despawn(obj):
	var valid_obj:bool = is_instance_valid(obj)
	if valid_obj:
		obj.queue_free()
		return 1
	else:
		return 0

func game_win():
	get_tree().quit()
