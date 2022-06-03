tool
extends Node2D

export(Color, RGBA) var center_color:Color setget set_center_color
export(Color, RGBA) var border_color:Color setget set_border_color
var default_alpha_mult:		float = 1.0
var default_lighten_value:	float = 1.0
var default_darken_value:	float = 1.0

func set_center_color(new_col) -> void:
	center_color = new_col
	update_colors()

func set_border_color(new_col) -> void:
	border_color = new_col
	update_colors()

func illuminate() -> void:
	pass 	#TODO

func _ready() -> void:
	var in_editor:bool = (Engine.editor_hint)
	if in_editor:
		set_owner(get_tree().edited_scene_root)
	update_colors()

func update_colors() -> void:
	var outline:		Sprite	= self.get_node_or_null("border")
	var valid_outline:	bool	= is_instance_valid(outline)
	if valid_outline:
		var outline_val:Color 	= self.get("border_color")
		outline.set("modulate", outline_val)

	var center:			Sprite	= self.get_node_or_null("center")
	var valid_center:	bool	= is_instance_valid(center)
	if valid_center:
		var center_val: Color 	= self.get("center_color")
		center.set("modulate", center_val)

func set_colors(center:Color = self.get("center_color"),
border:Color = self.get("border_color")) -> void:
	center_color = center
	border_color = border

func lighten_colors(lighten_amnt:float = default_lighten_value,
  change_center: bool = true,
  change_outline:bool = true) -> void:
	var center_val: Color = self.get("center_color")
	var outline_val:Color = self.get("border_color")
	if change_center:
		center_val  = center_val .lightened(lighten_amnt)
	if change_outline:
		outline_val = outline_val.lightened(lighten_amnt)
	self.set_colors(center_val, outline_val)
	self.update_colors()

func darken_colors(darken_amnt:float = default_darken_value,
change_center: bool = true,
change_outline:bool = true) -> void:
	var center_val: Color = self.get("center_color")
	var outline_val:Color = self.get("border_color")
	if change_center:
		center_val  = center_val .darkened(darken_amnt)
	if change_outline:
		outline_val = outline_val.darkened(darken_amnt)
	self.set_colors(center_val, outline_val)
	self.update_colors()

func invert_colors(
change_center: bool = true,
change_outline:bool = true) -> void:
	var center_val: Color = self.get("center_color")
	var outline_val:Color = self.get("border_color")
	if change_center:
		center_val = center_val.inverted()
	if change_outline:
		outline_val = outline_val.inverted()
	self.set_colors(center_val, outline_val)
	self.update_colors()

func increase_colors_transparency(alpha_mult:float = default_alpha_mult,
change_center: bool = true,
change_outline:bool = true) -> void:
	var center_val: Color = self.get("center_color")
	var outline_val:Color = self.get("border_color")
	if change_center:
		var new_alpha:float = center_val.a * alpha_mult
		center_val.a = new_alpha
	if change_outline:
		var new_alpha:float = outline_val.a * alpha_mult
		outline_val.a = new_alpha
	self.set_colors(center_val, outline_val)
	self.update_colors()

func greyscale_colors(
change_center: bool = true,
change_outline:bool = true) -> void:
	var center_val: Color = self.get("center_color")
	var outline_val:Color = self.get("border_color")
	if change_center:
		var gray_val:	float = center_val .gray()
		var grayed_col:	Color = Color(gray_val, gray_val, gray_val)
		center_val  = grayed_col
	if change_outline:
		var gray_val:	float = outline_val.gray()
		var grayed_col:	Color = Color(gray_val, gray_val, gray_val)
		outline_val = grayed_col
	self.set_colors(center_val, outline_val)
	self.update_colors()


