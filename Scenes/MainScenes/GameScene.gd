extends Node2D

signal game_finished(result)

var map_name = "Map1"
var map_node

var build_mode = false
var build_valid = false
var build_location
var build_type
var build_tile

var upgrade_mode = false
var upgrade_node

var current_wave = 0
var enemies_in_wave = 0
var boss_wave = false

var base_health = GameData.settings.starting_base_health
var current_money = GameData.settings.starting_money

onready var interface_effects = get_node("InterfaceEffects")

## music handler helper function class?
onready var background_music_upbeat = get_node("BackgroundMusicUpbeat")
onready var background_music_upbeat_tween = get_node("BackgroundMusicUpbeat/Tween")
onready var background_music_idle = get_node("BackgroundMusicIdle")
onready var background_music_idle_tween = get_node("BackgroundMusicIdle/Tween")
var normal_upbeat_music_track = true
var tween_needs_processing = false

var last_upbeat_position = 0
var last_idle_position = 0
var main_menu_mode = false
var skip_auto_turrets = false

var timer
var wave_timer
var auto_turrets_timer

func handle_main_menu():
	get_node("UI//HUD").hide()
	start_next_wave()

func _ready():
	setup_timers()
	var map_instance = load("res://Scenes/Maps/" + map_name + ".tscn").instance()
	add_child(map_instance)
	map_node = get_node(map_instance.name)
	
	if main_menu_mode:
		handle_main_menu()
	else:
		get_node("BackgroundMusicIdle").play()
		get_node("UI").update_health_bar(base_health)
		get_node("UI").setup_build_buttons(GameData.tower_data, get_node("UI/HUD/BuildBar"))
	
	get_node("UI").update_money(current_money, true)

func _process(_delta):
	if build_mode:
		update_tower_preview()
	
func _unhandled_input(event):
	if event.is_action_released("ui_cancel"):
		if build_mode:
			cancel_build_mode()
	elif event.is_action_released("ui_accept"):
		if build_mode:
			verify_and_build()

### build functions

func initiate_build_mode(tower_type):
	if upgrade_mode:
		cancel_upgrade_mode()
	if build_mode:
		cancel_build_mode()

	var cost = GameData.tower_data[tower_type].cost
	if (current_money - cost) < 0:
		GameData.play_error_sound(interface_effects)
		return

	GameData.play_button_sound(interface_effects)
		
	build_type = tower_type
	build_mode = true
	get_node("UI").set_tower_preview(build_type, get_global_mouse_position())
	
func update_tower_preview():
	var mouse_position = get_global_mouse_position()
	var current_tile = map_node.get_node("TowerExclusion").world_to_map(mouse_position)
	var tile_position = map_node.get_node("TowerExclusion").map_to_world(current_tile)
	
	if map_node.get_node("TowerExclusion").get_cellv(current_tile) == -1 or GameData.tower_data[build_type].build_anywhere:
		get_node("UI").update_tower_preview(tile_position, "ad54ff3c")
		build_valid = true
		build_location = tile_position
		build_tile = current_tile
	else:
		build_valid = false
		get_node("UI").update_tower_preview(tile_position, "adff4545")
	
func cancel_build_mode():
	build_mode = false
	build_valid = false
	var tower_preview = get_node_or_null("UI/TowerPreview")
	if tower_preview:
		tower_preview.free()
	
func verify_and_build():
	if build_valid:
		var new_tower = load("res://Scenes/Turrets/" + build_type + ".tscn").instance()
		new_tower.position = build_location
		new_tower.built = true
		new_tower.type = build_type
		if upgrade_mode:
			new_tower.from_upgrade = true
		new_tower.category = GameData.tower_data[build_type]["category"]
		map_node.get_node("Turrets").add_child(new_tower, true)
		if new_tower.category != "Ability":
			map_node.get_node("TowerExclusion").set_cellv(build_tile, 6)
			new_tower.connect("accept_click", self, "initiate_upgrade_mode", [new_tower])
			new_tower.connect("cancel_click", self, "cancel_upgrade_mode", [new_tower])
		else:
			new_tower.connect("ability_complete", self, 'on_ability_complete')
		
		if upgrade_mode:
			change_money(-(GameData.tower_data[build_type].upgrade_cost))
			GameData.play_upgrade_sound(interface_effects)
		else:
			change_money(-(GameData.tower_data[build_type].cost))
			if GameData.tower_data[build_type].category != "Ability":
				GameData.play_confirm_sound(interface_effects)
			
		cancel_build_mode()
		cancel_upgrade_mode()
		
func initiate_upgrade_mode(tower):
	if build_mode:
		return
		
	GameData.play_button_sound(interface_effects)
		
	upgrade_node = tower
	
	if not tower.get_node_or_null("RangeTexture"):
		var range_texture = Sprite.new()
		range_texture.set_name("RangeTexture")
		range_texture.position = Vector2(32,32)
		var scaling = GameData.tower_data[tower.type].range / 600.0
		range_texture.scale = Vector2(scaling, scaling)
		var texture = load("res://Assets/UI/range_overlay.png")
		range_texture.texture = texture
		tower.add_child(range_texture, true)
	
	var upgrades = GameData.tower_data[tower.type].upgrades
	if upgrades and upgrades.size():
		upgrade_mode = true
		get_node("UI").show_upgrade_bar(upgrades)
	else:
		get_node("UI").hide_upgrade_bar()
	
func cancel_upgrade_mode(_tower = null):
	if upgrade_node and is_instance_valid(upgrade_node) and upgrade_node.get_node_or_null("RangeTexture"):
		upgrade_node.get_node_or_null("RangeTexture").queue_free()
	
	upgrade_mode = false
	upgrade_node = null
	get_node("UI").hide_upgrade_bar()
	
func upgrade_requested(name):
	var cost = GameData.tower_data[name].upgrade_cost
	if (current_money - cost) < 0:
		GameData.play_error_sound(interface_effects)
		return
	
	build_type = name
	build_valid = true
	
	var current_tile = map_node.get_node("TowerExclusion").world_to_map(upgrade_node.position)
	var tile_position = map_node.get_node("TowerExclusion").map_to_world(current_tile)
	
	build_location = tile_position
	build_tile = current_tile
	
	upgrade_node.free()
	verify_and_build()

### wave functions

func start_next_wave():
	var wave_data = retrieve_wave_data()
	if wave_data:
		if 'turrets' in wave_data and wave_data.turrets and not skip_auto_turrets:
			timer.start(0.2); yield(timer, "timeout")
			process_auto_turrets(wave_data.turrets)

		timer.start(0.2); yield(timer, "timeout")
		boss_wave = wave_data.boss_wave
		play_music('upbeat')
		update_wave_data(false)
		
		var custom_path = "Path"
		if 'custom_path' in wave_data and wave_data.custom_path:
			custom_path = wave_data.custom_path
		spawn_enemies(wave_data.enemies, custom_path)
		
	else:
		emit_signal("game_finished", true, map_name)
		
func process_auto_turrets(turrets):
	for turret in turrets:
		var current_tile = Vector2(turret.coords.x, turret.coords.y)
		var tile_position = map_node.get_node("TowerExclusion").map_to_world(current_tile)
		build_type = turret.type
		
		if 'upgrade' in turret and turret.upgrade:
			upgrade_mode = true
			upgrade_node = null
			for active_turret in map_node.get_node("Turrets").get_children():
				if active_turret.position.x == tile_position.x and active_turret.position.y == tile_position.y:
					upgrade_node = active_turret
					upgrade_requested(turret.type)
					break
		elif map_node.get_node("TowerExclusion").get_cellv(current_tile) == -1 or GameData.tower_data[build_type].build_anywhere:
			build_valid = true
			build_location = tile_position
			build_tile = current_tile
			verify_and_build()
		
		auto_turrets_timer.start(turret.delay); yield(auto_turrets_timer, "timeout")

func retrieve_wave_data():
	if GameData.waves[map_name].size() <= current_wave and main_menu_mode:
		skip_auto_turrets = true
		current_wave = 0

	if GameData.waves[map_name].size() > current_wave:
		var wave_data = GameData.waves[map_name][current_wave]
		current_wave += 1
		enemies_in_wave = wave_data.enemies.size()
		return wave_data
	
func spawn_enemies(wave_data, path_name):
	for i in wave_data:
		var new_enemy = load("res://Scenes/Enemies/" + i.base + ".tscn").instance()
		new_enemy.category = i.category
		new_enemy.hide_hp_bar = main_menu_mode
		new_enemy.connect("base_damage", self, 'on_base_damage')
		new_enemy.connect("destroyed", self, 'on_enemy_destroyed')
		
		map_node.get_node(path_name).add_child(new_enemy, true)
		timer.start(i.delay); yield(timer, "timeout")

func wave_completed():
	play_music('idle')
	change_money(GameData.waves[map_name][current_wave - 1].cost)
	
	var time_between_waves = GameData.settings.time_between_waves
	wave_timer.start(time_between_waves); yield(wave_timer, "timeout")
	start_next_wave()

## enemy functions

func on_base_damage(damage):
	base_health -= damage
	update_wave_data()
	
	if base_health <= 0 and not main_menu_mode:
		emit_signal("game_finished", false, map_name)
	else:
		get_node("UI").update_health_bar(base_health)
		
func on_enemy_destroyed(category):
	var cost = GameData.enemy_data[category].cost
	change_money(cost)
	update_wave_data()
	
## ability functions

func on_ability_complete(enemies, type):
	if not enemies.size():
		change_money(GameData.tower_data[type].cost / 2)
	else:
		for enemy in enemies:
			enemy.on_hit(GameData.tower_data[type]["damage"], GameData.tower_data[type]["sound"])
	
## hud functions
	
func update_wave_data(subtract = true):
	if subtract:
		enemies_in_wave -= 1
	
	get_node("UI").update_wave_data(enemies_in_wave, current_wave)
	
	if subtract and enemies_in_wave <= 0:
		wave_completed()
		get_node("UI").wave_completed()
		
func change_money(moneyDelta):
	current_money = current_money + moneyDelta
	get_node("UI").update_money(current_money, false)
	
func play_music(name):
	if main_menu_mode:
		return
	if name == 'upbeat':
		if boss_wave:
			last_upbeat_position = 0
			normal_upbeat_music_track = false
			background_music_upbeat.stream = load("res://Assets/Audio/Music/Orbital Colossus.mp3")
		elif base_health <= 50 and normal_upbeat_music_track:
			normal_upbeat_music_track = false
			background_music_upbeat.stream = load("res://Assets/Audio/Music/n-Dimensions (Main Theme).mp3")
			last_upbeat_position = 0
		elif base_health > 50 and not normal_upbeat_music_track:
			normal_upbeat_music_track = true
			background_music_upbeat.stream = load("res://Assets/Audio/Music/Tactical Pursuit.mp3")
			last_upbeat_position = 0
		
		last_idle_position = background_music_idle.get_playback_position()
		tween_needs_processing = true
		background_music_idle_tween.interpolate_property(background_music_idle, 'volume_db', 1, -100, 2, Tween.TRANS_LINEAR, Tween.EASE_IN, 0)
		background_music_idle_tween.start()
	elif name == 'idle':
		last_upbeat_position = background_music_upbeat.get_playback_position()
		tween_needs_processing = true
		background_music_upbeat_tween.interpolate_property(background_music_upbeat, 'volume_db', 1, -100, 2, Tween.TRANS_LINEAR, Tween.EASE_IN, 0)
		background_music_upbeat_tween.start()


func _on_bgmusicidle_tween_completed(_object, _key):
	if tween_needs_processing:
		tween_needs_processing = false
		background_music_idle.stop()
		background_music_upbeat.volume_db = -100
		background_music_upbeat.play(last_upbeat_position)
		background_music_upbeat_tween.interpolate_property(background_music_upbeat, 'volume_db', -100, 1, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN, 0)
		background_music_upbeat_tween.start()
		

func _on_bgmusicupbeat_tween_completed(_object, _key):
	if tween_needs_processing:
		tween_needs_processing = false
		background_music_upbeat.stop()
		background_music_idle.volume_db = -100
		background_music_idle.play(last_idle_position)
		background_music_idle_tween.interpolate_property(background_music_idle, 'volume_db', -100, 1, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN, 0)
		background_music_idle_tween.start()

func setup_timers():
	timer = Timer.new()
	timer.one_shot = true
	timer.autostart = false
	add_child(timer)
	
	wave_timer = Timer.new()
	wave_timer.one_shot = true
	wave_timer.autostart = false
	add_child(wave_timer)
	
	auto_turrets_timer = Timer.new()
	auto_turrets_timer.one_shot = true
	auto_turrets_timer.autostart = false
	add_child(auto_turrets_timer)
