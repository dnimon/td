extends "res://Scenes/UIScenes/WindowPopup.gd"

const UIBuilder = preload("res://CommonScripts/UIBuilder.gd")
onready var ui_builder = UIBuilder.new(self)

var current_data

func process_data(data, item_key):
	if not data:
		return
		
	current_data = data
	
	clear_scroll_container()
	window_title = item_key
	ui_builder.build_ui(data, GameData.editor_data_map)
		
	open_popup()

func value_changed(value, item_key, label_node = null):
	if label_node:
		label_node.text = str(value)
		
	current_data[item_key] = value
