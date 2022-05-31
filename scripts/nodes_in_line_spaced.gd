tool
extends Node2D

export(int) 	 var num_nodes 	= 1   setget set_node_count
export(int) 	 var padding  	= 60  setget set_spacing
export(Resource) var resource		  setget set_resource

func set_spacing(space):
	padding = space
	update_nodes()

func set_node_count(new_count):
	num_nodes = new_count
	update_nodes()

func set_resource(new_resource = get("resource")):
	if is_instance_valid(new_resource):
		resource = new_resource
	elif is_instance_valid(resource):
		pass #do nothing
	else:
		resource = load("res://prefabs/aim_segment.tscn")
	update_nodes()

func get_resource_instance():
	if is_instance_valid(resource):
		return resource.instance()
	else:
		return null

func add_new_instances(count = num_nodes):
	for i in range(count):
		var node = get_resource_instance()	#make new node
		if (node != null):
			node.position = get_relative_node_pos(i)	#get spawn pos
			add_child(node)

func get_relative_node_pos(idx):
	var linear_pos = padding * idx
	return Vector2(0, linear_pos)

func get_global_node_pos(idx = self.get_child_count()):
	var pos = get_relative_node_pos(idx)
	var glob_pos = self.get("global_position") + pos.rotated(rotation)
	return glob_pos

func remove_all_children():
	for node in self.get_children():
		if is_instance_valid(node):
			node.queue_free()

func update_nodes():
	remove_all_children()
	add_new_instances()

func node_count_ok():
	var child_count   = get_child_count()
	var nodes_ok:bool = (child_count == num_nodes)
	return nodes_ok

func _ready():
	#set_resource(resource)
	set_owner(get_tree().root)
	if Engine.editor_hint:
		set_owner(get_tree().edited_scene_root)

