extends Node

# Autoloads can’t use Inspector assignment, so load directly
var player_scene: PackedScene = load("res://Assets/Scenes/Player.tscn")

var starting_area: int = 1
var current_area: int = 1
var area_path: String = "res://Assets/Scenes/Areas/"

var energy_cells: int = 0
var area_container: Node2D
var players: Array = []
var hud: HUD

func _ready():
	# Grab AreaContainer directly
	area_container = get_tree().current_scene.get_node("AreaContainer")
	if area_container == null:
		push_error("AreaContainer not found in current scene!")
		return

	# Grab SubViewports
	var vp1 = get_tree().current_scene.get_node("CanvasLayer/SubViewportContainerP1/SubViewportP1")
	var vp2 = get_tree().current_scene.get_node("CanvasLayer/SubViewportContainerP2/SubViewportP2")

	# Share the same world
	var world = get_tree().root.world_2d
	vp1.world_2d = world
	vp2.world_2d = world

	# Dynamically size each SubViewport
	var window_size = get_viewport().size
	vp1.size = Vector2(window_size.x / 2, window_size.y)
	vp2.size = Vector2(window_size.x / 2, window_size.y)

	# Spawn players
	var p1 = player_scene.instantiate()
	p1.input_prefix = "P1"
	vp1.add_child(p1)
	players.append(p1)

	var p2 = player_scene.instantiate()
	p2.input_prefix = "P2"
	vp2.add_child(p2)
	players.append(p2)

	load_area(starting_area)


func reset_energy_cells():
	energy_cells = 0
	if hud:
		hud.update_energy_label(energy_cells)
		hud.portal_closed()


func add_energy_cell():
	energy_cells += 1
	if hud:
		hud.update_energy_label(energy_cells)
	if energy_cells >= 4:
		var portal = get_tree().get_first_node_in_group("AreaExits") as AreaExit
		if portal:
			portal.open()
		if hud:
			hud.portal_opened()


func load_area(area_number: int):
	if area_container == null:
		push_error("AreaContainer is null, cannot load area.")
		return

	current_area = area_number
	var full_path = area_path + "area_" + str(current_area) + ".tscn"
	var scene = load(full_path) as PackedScene
	if !scene:
		push_error("Could not load area scene: " + full_path)
		return

	# Clear old children
	for child in area_container.get_children():
		child.queue_free()
		await child.tree_exited

	# Instance new area
	var instance = scene.instantiate()
	area_container.add_child(instance)

	reset_energy_cells()

	# Teleport players to start marker if present
	var playerStartPosition = get_tree().get_first_node_in_group("player_start")
	if playerStartPosition:
		for p in players:
			p.teleport_to_location(playerStartPosition.position)


func next_area():
	current_area += 1
	load_area(current_area)


func death():
	# Clear hazards
	for fireball in get_tree().get_nodes_in_group("fireball"):
		fireball.queue_free()

	# Play death sound if available
	var sounds_node = get_tree().get_first_node_in_group("sounds")
	if sounds_node:
		var death_sound = sounds_node.get_node_or_null("Death")
		if death_sound and death_sound is AudioStreamPlayer and death_sound.stream:
			death_sound.play()

	# Reload the current area
	load_area(current_area)

	# Respawn both players at the start position
	var playerStartPosition = get_tree().get_first_node_in_group("player_start")
	if playerStartPosition:
		for p in players:
			p.teleport_to_location(playerStartPosition.position)
