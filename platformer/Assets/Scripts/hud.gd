extends Control
class_name HUD

@export var energy_cell_label : Label
@export var portal_label : Label

func _ready():
	# Toggle visibility of the Buttons group depending on platform
	$Buttons.visible = OS.has_feature("mobile")


func update_energy_label(number : int):
	energy_cell_label.text = "x " + str(number)
	
func portal_opened():
	portal_label.text = "Portal Open"
	
func portal_closed():
	portal_label.text = "Portal closed, Get More Cells!"
