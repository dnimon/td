extends CanvasLayer

onready var hp_bar = get_node("HUD/InfoBar/M/H/HPWrapper/HP")
onready var hp_bar_tween = get_node("HUD/InfoBar/M/H/HPWrapper/HP/Tween")

onready var money = get_node("HUD/InfoBar/M/H/Money")
onready var money_tween = get_node("HUD/InfoBar/M/H/Money/Tween")

onready var wave_wrapper = get_node("HUD/InfoBar/M/H/WaveWrapper")
onready var wave = get_node("HUD/InfoBar/M/H/WaveWrapper/Wave")
onready var remaining = get_node("HUD/InfoBar/M/H/WaveWrapper/Remaining")

onready var upgrade_bar = get_node("HUD/UpgradeBar")

onready var interface_effects = get_parent().get_node("InterfaceEffects")

var money_number
var remaining_number

func _ready():
	for i in upgrade_bar.get_children():
		i.connect("pressed", self, "upgrade_requested", [i.get_name()])

### build functions

func set_tower_preview(tower_type, mouse_position):
	var drag_tower = load("res://Scenes/Turrets/" + tower_type + ".tscn").instance()
	drag_tower.set_name("DragTower")
	drag_tower.modulate = Color("ad54ff3c")
	
	var range_texture = Sprite.new()
	range_texture.set_name("RangeTexture")
	range_texture.position = Vector2(32,32)
	var scaling = GameData.tower_data[tower_type].range / 600.0
	range_texture.scale = Vector2(scaling, scaling)
	var texture = load("res://Assets/UI/range_overlay.png")
	range_texture.texture = texture
	range_texture.modulate = Color("ad54ff3c")
	
	var control	= Control.new()
	control.add_child(drag_tower, true)
	control.add_child(range_texture, true)
	control.rect_position = mouse_position
	control.set_name("TowerPreview")
	add_child(control, true)
	move_child(get_node("TowerPreview"), 0)

func update_tower_preview(new_position, color):
	get_node("TowerPreview").rect_position = new_position
	if get_node("TowerPreview/DragTower").modulate != Color(color):
		get_node("TowerPreview/DragTower").modulate = Color(color)
		get_node("TowerPreview/RangeTexture").modulate = Color(color)


### game control functions

func _on_PausePlay_pressed():
	GameData.play_button_sound(interface_effects)
	if get_parent().build_mode:
		get_parent().cancel_build_mode()
	if get_tree().is_paused():
		get_tree().paused = false
	elif get_parent().current_wave == 0:
		get_parent().start_next_wave()
	else:
		get_tree().paused = true


func _on_SpeedUp_pressed():
	GameData.play_button_sound(interface_effects)
	if get_parent().build_mode:
		get_parent().cancel_build_mode()
	if Engine.get_time_scale() == 2.0:
		Engine.set_time_scale(1.0)
	else:
		Engine.set_time_scale(2.0)

func update_health_bar(base_health):
	hp_bar_tween.interpolate_property(hp_bar, 'value', hp_bar.value, base_health, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	hp_bar_tween.start()
	if base_health >= 60:
		hp_bar.set_tint_progress("4eff15")
	elif base_health <= 60 and base_health >= 25:
		hp_bar.set_tint_progress("e1be32")
	else:
		hp_bar.set_tint_progress("e11e1e")

func update_money(current_money, immediate = false):
	if immediate:
		money.text = str(current_money)
	else:
		money_tween.interpolate_property(self, 'money_number', int(money.text), current_money, 0.7, Tween.TRANS_CIRC, Tween.EASE_IN_OUT)
		money_tween.start()
		
func _on_money_Tween_tween_step(_object, _key, _elapsed, value):
	money.text = str(int(value))
	
func update_wave_data(enemies_in_wave, current_wave):
	if not wave_wrapper.visible:
		wave_wrapper.visible = true
	
	if wave.text != str(current_wave):
		wave.text = str(current_wave)
	
	if remaining.text != str(enemies_in_wave):
		remaining.text = str(enemies_in_wave)
		
func wave_completed():
	remaining.text = "COMPLETE!"
	
func show_upgrade_bar(upgrades):
	upgrade_bar.visible = true
	var new_tower_data = {}
	for name in upgrades:
		new_tower_data[name] = GameData.tower_data[name]
	print(new_tower_data)
	setup_build_buttons(new_tower_data, get_node("HUD/UpgradeBar"), true, "upgrade_requested")

func hide_upgrade_bar():
	upgrade_bar.visible = false

func upgrade_requested(name):
	get_parent().upgrade_requested(name)
	
func setup_build_buttons(buttons, parent_node, show_regardless = false, func_name = "initiate_build_mode"):
	for child in parent_node.get_children():
		child.free()
	
	for name in buttons:
		var item = buttons[name]
		if show_regardless or ('in_build_menu' in item and item.in_build_menu):
			var button = Button.new()
			button.name = name
			button.rect_min_size = Vector2(80, 80)
			button.size_flags_horizontal = TextureButton.SIZE_SHRINK_CENTER
			button.size_flags_vertical = TextureButton.SIZE_SHRINK_CENTER
			button.margin_left = 10
			button.connect("pressed", get_parent(), func_name, [button.get_name()])
			
			var icon
			if 'icon' in item:
				icon = TextureRect.new()
				icon.texture = load(item.icon)
				icon.expand = true
			else:
				icon = Label.new()
				icon.text = name
				icon.autowrap = true
				icon.align = Label.ALIGN_CENTER
				icon.valign = Label.ALIGN_CENTER
		
			icon.rect_min_size = Vector2(60, 60)
			icon.margin_left = 10
			icon.margin_top = 10
			icon.margin_right = -10
			icon.margin_bottom = -10
			icon.name = "Icon"
				
			button.add_child(icon)
			parent_node.add_child(button)
