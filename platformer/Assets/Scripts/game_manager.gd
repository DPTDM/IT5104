extends Node

var current_area = 3
var area_path = "res://Assets/Scenes/Areas/"




func next_level():
	current_area += 1
	var full_path = area_path + "area_" + str(current_area) + ".tscn"
	get_tree().change_scene_to_file(full_path)

func death():
	
	get_tree().paused = true
	await get_tree().create_timer(1.0).timeout
	get_tree().paused = false

	var full_path = area_path + "area_" + str(current_area) + ".tscn"
	get_tree().change_scene_to_file(full_path)
	
