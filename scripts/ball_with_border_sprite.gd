tool
extends Sprite

export(Color, RGBA) var center_color setget set_center_color
export(Color, RGBA) var border_color setget set_border_color
var default_alpha_mult 	  = 1
var default_lighten_value = 1
var default_darken_value  = 1

func set_center_color(new_col):
	center_color = new_col
	update_colors()

func set_border_color(new_col):
	border_color = new_col
	update_colors()

func illuminate():
	pass 	#TODO

func _ready():
	if Engine.editor_hint:
		set_owner(get_tree().edited_scene_root)
	update_colors()

func update_colors():
	get_node("border").modulate = border_color
	get_node("center").modulate = center_color

func set_colors(center:Color, border:Color):
	center_color = center
	border_color = border

func lighten_colors(
lighten_amnt:	   float = default_lighten_value,
change_center_color:bool = true,
change_border_color:bool = true):
	var center 	 = self.get("center_color")
	var border   = self.get("border_color")
	if change_center_color:
		center = center.lightened(lighten_amnt)
	if change_border_color:
		border = border.lightened(lighten_amnt)
	self.set_colors(center, border)
	self.update_colors()

func darken_colors(
darken_amnt:	   float = default_darken_value,
change_center_color:bool = true,
change_border_color:bool = true):
	var center 	 = self.get("center_color")
	var border   = self.get("border_color")
	if change_center_color:
		center = center.darkened(darken_amnt)
	if change_border_color:
		border = border.darkened(darken_amnt)
	self.set_colors(center, border)
	self.update_colors()

func invert_colors(
change_center_color:bool = true,
change_border_color:bool = true):
	var center 	 = self.get("center_color")
	var border   = self.get("border_color")
	if change_center_color:
		center = center.inverted()
	if change_border_color:
		border = border.inverted()
	self.set_colors(center, border)
	self.update_colors()

func increase_colors_transparency(
alpha_mult: 	   float = default_alpha_mult,
change_center_color:bool = true,
change_border_color:bool = true):
	var center:Color = self.get("center_color")
	var border:Color = self.get("border_color")
	if change_center_color:
		center.a = center.a * alpha_mult
	if change_border_color:
		border.a = border.a * alpha_mult
	self.set_colors(center, border)
	self.update_colors()

func greyscale_colors(
change_center_color:bool = true,
change_border_color:bool = true):
	var center:Color = self.get("center_color")
	var border:Color = self.get("border_color")
	if change_center_color:
		var gray_val   = center.gray()
		var grayed_col = Color(gray_val, gray_val, gray_val)
		center = grayed_col
	if change_border_color:
		var gray_val   = border.gray()
		var grayed_col = Color(gray_val, gray_val, gray_val)
		border = grayed_col
	self.set_colors(center, border)
	self.update_colors()


