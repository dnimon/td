extends Node

var last_map_name

var interface_effects

func _ready():
	link_main_menu()
	link_setting_change()
	check_fps_monitor()
	
func link_setting_change():
	# warning-ignore:return_value_discarded
	GameData.connect("setting_updated", self, "setting_change")

func check_fps_monitor():
	if GameData.settings.show_fps_monitor:
		$Monitor.add_perf_monitor(Performance.TIME_FPS, "FPS")
	else:
		var monitor_container = $Monitor.get_node_or_null("MarginContainer//HBoxContainer")
		if monitor_container:
			var monitor_children = monitor_container.get_children()
			for monitor_child in monitor_children:
				monitor_child.free()
		
func setting_change(setting_key, _value):
	if setting_key == "show_fps_monitor":
		check_fps_monitor()
	
func load_main_menu():
	var congrats_menu = get_node_or_null("CongratsMenu")
	if congrats_menu and is_instance_valid(congrats_menu):
		congrats_menu.queue_free()
	var main_menu = load("res://Scenes/UIScenes/MainMenu.tscn").instance()
	add_child(main_menu)
	link_main_menu()
	
func load_congrats_menu():
	var congrats_menu = load("res://Scenes/UIScenes/CongratsMenu.tscn").instance()
	add_child(congrats_menu)
	# warning-ignore:return_value_discarded
	get_node("CongratsMenu/Container/VBoxContainer/Continue").connect("pressed", self, "on_continue_pressed")
	# warning-ignore:return_value_discarded
	get_node("CongratsMenu/Container/VBoxContainer/MainMenu").connect("pressed", self, "on_congrats_main_menu")
	# warning-ignore:return_value_discarded
	get_node("CongratsMenu/Container/VBoxContainer/Quit").connect("pressed", self, "on_quit_pressed")

func link_main_menu():
	# warning-ignore:return_value_discarded
	get_node("MainMenu/Container/VBoxContainer/NewGame").connect("pressed", self, "on_new_game_pressed")
	# warning-ignore:return_value_discarded
	get_node("MainMenu/Container/VBoxContainer/Settings").connect("pressed", self, "on_settings_pressed")
	# warning-ignore:return_value_discarded
	get_node("MainMenu/Container/VBoxContainer/Editor").connect("pressed", self, "on_editor_pressed")
	# warning-ignore:return_value_discarded
	get_node("MainMenu/Container/VBoxContainer/About").connect("pressed", self, "on_about_pressed")
	# warning-ignore:return_value_discarded
	get_node("MainMenu/Container/VBoxContainer/Quit").connect("pressed", self, "on_quit_pressed")
	interface_effects = get_node("MainMenu/InterfaceEffects")
	
	var map_name = GameData.settings.main_menu_map
	var game_scene = load("res://Scenes/MainScenes/GameScene.tscn").instance()
	game_scene.map_name = map_name
	game_scene.main_menu_mode = true
	add_child(game_scene)
	move_child(game_scene, 0)

func on_new_game_pressed():
	get_node("GameScene").free()
	GameData.play_button_sound(interface_effects)
	last_map_name = null
	get_node("MainMenu").queue_free()
	load_game_scene()
	
func on_settings_pressed():
	GameData.play_button_sound(interface_effects)
	get_node("MainMenu//SettingsPopup").open_popup()
	
func on_editor_pressed():
	GameData.play_button_sound(interface_effects)
	get_node("MainMenu//EditorPopup").open_popup()
	
func on_about_pressed():
	GameData.play_button_sound(interface_effects)
	get_node("MainMenu//AboutPopup").open_popup()
	
func on_continue_pressed():
	GameData.play_button_sound(interface_effects)
	var map_order = GameData.settings.map_order
	if map_order[last_map_name]:
		get_node("CongratsMenu").queue_free()
		var new_map = map_order[last_map_name]
		load_game_scene(new_map)
		
func on_congrats_main_menu():
	load_main_menu()
	
func load_game_scene(map_name = null):
	if not map_name:
		map_name = GameData.settings.starting_map
		
	var game_scene = load("res://Scenes/MainScenes/GameScene.tscn").instance()
	game_scene.map_name = map_name
	game_scene.connect("game_finished", self, 'unload_game')
	add_child(game_scene)
	
func on_quit_pressed():
	GameData.play_button_sound(interface_effects)
	get_tree().quit()

func unload_game(result, map_name):
	last_map_name = map_name
	get_node("GameScene").queue_free()
	if not result:
		load_main_menu()
	else:
		load_congrats_menu()
