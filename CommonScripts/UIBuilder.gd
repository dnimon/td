extends Node

var parent_node

func _init(given_parent_node):
	parent_node = given_parent_node
	
func add_ui_to_node(node):
	parent_node.add_ui(node)

func build_ui(data, map):
	for key in data:
		if key in map:
			var map_data = map[key]
			var data_value = data[key]
			
			var label = Label.new()
			label.text = map_data.label
			label.autowrap = true
			add_ui_to_node(label)
			
			if map_data.type == "slider":
				var slider_label = Label.new()
				slider_label.text = str(data_value)
				slider_label.autowrap = true
				slider_label.align = Label.ALIGN_CENTER
				
				var slider = HSlider.new()
				slider.min_value = map_data.min
				slider.max_value = map_data.max
				slider.value = data_value
				if 'step' in map_data:
					slider.step = map_data.step
				slider.connect("value_changed", parent_node, "value_changed", [key, slider_label])
				
				add_ui_to_node(slider)
				add_ui_to_node(slider_label)
			elif map_data.type == "checkbox":
				var checkbox = CheckButton.new()
				checkbox.pressed = data_value
				checkbox.connect("toggled", parent_node, "value_changed", [key])
				checkbox.size_flags_horizontal = CheckButton.SIZE_SHRINK_CENTER
				add_ui_to_node(checkbox)
			elif map_data.type == "dropdown":
				var dropdown = OptionButton.new()
				dropdown.text = data_value
				
				var idx = 0
				var current_idx = 0
				for dropdown_option in map_data.options:
					dropdown.add_item(dropdown_option, idx)
					
					if dropdown_option == data_value:
						current_idx = idx
					
					idx += 1
				dropdown.selected = current_idx
				dropdown.connect("item_selected", self, "dropdown_changed", [key, map_data.options])
				add_ui_to_node(dropdown)
				
				var dropdown_label = Label.new()
				dropdown_label.text = ""
				dropdown_label.autowrap = true
				dropdown_label.align = Label.ALIGN_CENTER
				add_ui_to_node(dropdown_label)
			elif map_data.type == "text":
				var line_edit = LineEdit.new()
				line_edit.text = str(data_value)
				line_edit.connect("text_changed", parent_node, "value_changed", [key])
				add_ui_to_node(line_edit)

func dropdown_changed(index, key, options):
	var loop_idx = 0
	for option in options:
		if index == loop_idx:
			var value = option
			parent_node.value_changed(value, key)
			break
		loop_idx += 1
