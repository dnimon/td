extends WindowDialog

func open_popup():
	self.popup_centered()
	
func add_ui(node):
	add_to_scroll_container(node)

func add_to_scroll_container(node):
	get_node("ScrollContainer//VBoxContainer").add_child(node)

func clear_scroll_container():
	for child in get_node("ScrollContainer//VBoxContainer").get_children():
		child.queue_free()
