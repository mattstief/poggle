extends Node2D
export(float) var shot_speed:		float = 1100.0
export(float) var shot_gravity:		float = 1200.0
export(float) var shot_bounciness:	float = 1.0
var shots_remaining:int 	= 20 setget set_shots_remaining
var shots_on_screen:int 	= 0
var pegs_remaining:	int  	= 0
var despawn_queue:	Array	= []
var firing_blocked:	bool 	= false

func print_connect_err(failed_signal:String, err) -> void:
	print("error connecting ", failed_signal, err)

func initialize_pegs() -> void:
	var peg_collection:		Array 	= get_tree().get_nodes_in_group("pegs")
	var starting_peg_count:	int 	= peg_collection.size()
	set("pegs_remaining", starting_peg_count)
	for peg in peg_collection:
		var peg_err = peg.connect("peg_collision", self, "_on_peg_collision")
		if peg_err:
			print_connect_err("peg_err", peg_err)

func initialize_gun() -> void:
	var barrel:			Node2D 	= get_node_or_null("gun/barrel")
	var barrel_exists:	bool 	= is_instance_valid(barrel)
	if barrel_exists:
		var shoot_err  = barrel.connect("shoot_input", self, "_on_shoot_input")
		var input_err  = barrel.connect("player_input", self, "_on_player_input")
		var sprite_err = barrel.connect("spawn_obj", self, "_on_spawn_obj")
		if shoot_err:
			print_connect_err("shoot_err", shoot_err)
		if input_err:
			print_connect_err("input_err", input_err)
		if sprite_err:
			print_connect_err("sprite_err", sprite_err)
	else:
		print("no gun?! exiting")
		get_tree().quit()

func initialize_bucket() -> void:
	var catcher:		Node2D 	= get_node_or_null("catcher_container/catcher_body/catcher")
	var catcher_exists:	bool 	= is_instance_valid(catcher)
	if catcher_exists:
		var catch_err = catcher.connect("projectile_caught", self, "_on_catch")
		if catch_err:
			print_connect_err("catch_err", catch_err)
	else:
		print("no catcher")

func initialize_UI() -> void:
	var UI:			Node2D 	= get_node_or_null("UI")
	var UI_exists:	bool 	= is_instance_valid(UI)
	if UI_exists:
		var UI_err = UI.connect("UI_signal", self, "_on_UI_signal")
		if UI_err:
			print_connect_err("UI_err", UI_err)
	else:
		print("no UI in scene!")
		get_tree().quit()
	update_ammo_UI()

func initialize_ability() -> void:
	var ability: 		Node2D 	= get_node_or_null("Ability")
	var ability_exists: bool	= is_instance_valid(ability)
	if ability_exists:
		var ability_err = ability.connect("ability_signal", self, "_on_ability_signal")
		if ability_err:
			print_connect_err("ability_err", ability_err)
	else:
		print("no special ability active!")
	update_ammo_UI()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	var vp:Node2D = get_node_or_null("root/viewport")
	if vp != null:
		print("viewport_rect: ", vp.get_visible_rect())
	initialize_pegs()
	initialize_gun()
	initialize_bucket()
	initialize_UI()
	initialize_ability()

func _on_spawn_obj(obj:Object):
	self.add_child(obj)

func _on_shoot_input(asset:Resource, rot:float, pos:Vector2) -> void:
	var shot_allowed:bool = can_spawn_projectile()
	print("shot_allowed: ", shot_allowed)
	if shot_allowed:
		var success = spawn_projectile(asset, rot, pos)
		print("success: ", success)
		if success:
			begin_shot()

func _on_peg_collision(peg:Node2D, behavior:String) -> void:
	if behavior == "queue despawn":
		get("despawn_queue").append(peg)
	elif behavior == "despawn":
		var success:bool = despawn(peg)
		if !success:
			print("failed to despawn peg")
	else:
		pass

func _on_catch(catcher:Node2D) -> void:
	print("caught!")
	var action:		String 	= catcher.get("action")
	self.catch_event(action)
	var UI_node:	Node2D 	= self.get_node_or_null("UI")
	var UI_valid:	bool 	= is_instance_valid(UI_node)
	if UI_valid:
		UI_node.draw_event(action, catcher)

func _on_UI_signal(arg:String) -> void:
	if arg == "increase_ammo":
		var new_remainder:int = self.get("shots_remaining") + 1
		self.set("shots_remaining", new_remainder)
	if arg == "prevent_firing":
		self.set("firing_blocked", true)
	if arg == "allow_firing":
		self.set("firing_blocked", false)

func _on_player_input(arg:String) -> void:
	if(arg == "special_action_just_pressed"):
		#can only use ability if a ball is on screen
		var can_use_special:bool = !firing_blocked
		if can_use_special:
			#TODO validate $projectile existence
			$Ability.try_ability($projectile)

func _on_ability_signal(arg:String) -> void:
	print("ability signal received", arg)

func find_active_projectile():
	pass

func catch_event(arg:String = "default") -> void:
	if (arg == "free ball"):
		pass

func can_spawn_projectile() -> bool:
	if self.get("firing_blocked"):
		return false
	var shot_ammo:int = self.get("shots_remaining")
	var shots_out:int = self.get("shots_on_screen")
	var existing_projectile:bool = (shots_out > 0)
	var out_of_shots:		bool = (shot_ammo < 1)
	if (existing_projectile or out_of_shots):
		return false
	else:
		return true

func spawn_projectile(asset:Resource, rot:float, pos:Vector2) -> bool:
	var bullet:Object = asset.instance()
	if is_instance_valid(bullet):
		var failure:bool = bullet.connect("projectile_despawn", self, "_on_projectile_despawn")
		if failure:
			return false
		bullet.set("bounciness",self.get("shot_bounciness"))
		bullet.set("gravity"   ,self.get("shot_gravity"))
		bullet.set("speed"	   ,self.get("shot_speed"))
		bullet.set("rotation", rot)
		bullet.set("position", pos)
		self.add_child(bullet)
		return true
	else:
		return false

func set_shots_remaining(new_remainder:int = shots_remaining) -> void:
	shots_remaining = new_remainder
	update_ammo_UI()

func update_ammo_UI(count:int = shots_remaining) -> void:
	var ammo_ui:		Node2D 	= self.get_node_or_null("UI/ammo")
	var valid_ammo_ui:	bool 	= is_instance_valid(ammo_ui)
	if valid_ammo_ui:
		ammo_ui.set_node_count(count)

func begin_shot() -> void:
	var on_screen:int = self.get("shots_on_screen") + 1
	var remaining:int = self.get("shots_remaining") - 1
	self.set("shots_on_screen", on_screen)
	self.set("shots_remaining", remaining)

#called when a shot is no longer bouncing about
func _on_projectile_despawn() -> void:
	remove_pegs()
	expend_shot()

func remove_pegs() -> void:
	var arr:		Array 	= self.get("despawn_queue")
	var peg_count:	int 	= 0
	for obj in arr:
		if is_peg(obj):
			peg_count = peg_count + 1
	var pegs_left:int = (self.get("pegs_remaining") - peg_count)
	set("pegs_remaining", pegs_left)
	flush_arr(arr)

func expend_shot() -> void:
	var old_shots_out:	int	= self.get("shots_on_screen")
	var curr_shots_out:	int	= (old_shots_out - 1)
	set("shots_on_screen", curr_shots_out)

#despawns all elements in the arr and clears it
func flush_arr(arr:Array) -> void:
	for obj in arr:
		var success = despawn(obj)
		if success:
			yield(get_tree().create_timer(0.1), "timeout")
	arr.clear()

func is_peg(obj:Object) -> bool:
	var valid_obj:bool = is_instance_valid(obj)
	if valid_obj:
		return (obj.is_in_group("pegs"))
	else:
		return false

#despawns instance, returns 1 on success or 0 on fail
func despawn(obj) -> bool:
	var valid_obj:bool = is_instance_valid(obj)
	if valid_obj:
		obj.queue_free()
		return true
	else:
		return false

func game_win() -> void:
	get_tree().quit()
