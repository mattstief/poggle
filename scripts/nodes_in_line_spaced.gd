tool
extends Node2D

export(int) 	 var num_nodes:	int 	= 1   	setget set_node_count
export(float) 	 var padding:	float  	= 60.0  setget set_spacing
export(Resource) var resource:	Resource		setget set_resource

func set_spacing(space:float) -> void:
	padding = space
	update_nodes()

func set_node_count(new_count:int) -> void:
	num_nodes = new_count
	update_nodes()

func set_resource(new_resource:Resource = get("resource")) -> void:
	var valid_resource:bool	= is_instance_valid(new_resource)
	if valid_resource:
		resource = new_resource
	else:
		resource = load("res://prefabs/aim_segment.tscn")
	update_nodes()

func get_resource_instance() -> Object:
	var curr_resource:	Resource 	= self.get("resource")
	var valid_resource:	bool 		= is_instance_valid(curr_resource)
	if valid_resource:
		return curr_resource.instance()
	else:
		return null

func add_new_instances(count:int = num_nodes) -> void:
	for i in range(count):
		var node:Object = get_resource_instance()	#make new node
		if (node != null):
			node.position = get_relative_node_pos(i)	#get spawn pos
			add_child(node)

func get_relative_node_pos(idx:int) -> Vector2:
	var linear_pos:float = (padding * idx)
	return Vector2(0.0, linear_pos)

func get_global_node_pos(idx:int = self.get_child_count()) -> Vector2:
	var pos:		Vector2 = get_relative_node_pos(idx)
	var glob_pos:	Vector2 = self.get("global_position") + pos.rotated(rotation)
	return glob_pos

func remove_all_children() -> void:
	for node in self.get_children():
		if is_instance_valid(node):
			node.queue_free()

func update_nodes() -> void:
	remove_all_children()
	add_new_instances()

func node_count_ok() -> bool:
	var child_count:int		= get_child_count()
	var nodes_ok:	bool	= (child_count == num_nodes)
	return nodes_ok

func _ready() -> void:
	set_owner(get_tree().root)
	var in_editor:bool = (Engine.editor_hint)
	if in_editor:
		set_owner(get_tree().edited_scene_root)

