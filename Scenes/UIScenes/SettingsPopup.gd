extends "res://Scenes/UIScenes/WindowPopup.gd"

const UIBuilder = preload("res://CommonScripts/UIBuilder.gd")
onready var ui_builder = UIBuilder.new(self)

func _ready():
	process_settings()
	
func process_settings():
	ui_builder.build_ui(GameData.settings, GameData.settings_map)

func value_changed(value, setting_key, label_node = null):
	if label_node:
		label_node.text = str(value)
	GameData.update_setting(setting_key, value)
