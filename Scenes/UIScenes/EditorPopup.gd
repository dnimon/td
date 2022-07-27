extends "res://Scenes/UIScenes/WindowPopup.gd"

var edit_icon = preload("res://Assets/Icons/gear.png")

func _ready():
	process_editor()
	
func process_editor():
	process_turrets()
	process_enemies()
	
func process_turrets():
	var turrets_tree = get_node("VBoxContainer/TabContainer/Turrets/VBoxContainer/Tree")
	create_tree(turrets_tree, GameData.tower_data)
	
func process_enemies():
	var turrets_tree = get_node("VBoxContainer/TabContainer/Enemies/VBoxContainer/Tree")
	create_tree(turrets_tree, GameData.enemy_data)
		
func create_tree(tree, data):
	var root = tree.create_item()
	tree.set_hide_root(true)
	
	for key in data:
		var child = tree.create_item(root)
		child.set_text(0, key)
		child.add_button(0, edit_icon)
		
	tree.connect('button_pressed', self, 'edit_requested', [data])

func edit_requested(item, _column, _id, data):
	var item_key = item.get_text(0)
	get_parent().get_node("EditorItemPopup").process_data(data[item_key], item_key)
