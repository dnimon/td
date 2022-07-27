extends "res://Scenes/UIScenes/WindowPopup.gd"

const FS = preload("res://CommonScripts/FS.gd")
onready var fs = FS.new()
var licenses_path = "res://Assets/AssetLicenses/"

func _ready():
	process_license_files()
	
func process_license_files():
	var license_files = fs.list_files_in_directory(licenses_path)
	for license_file_name in license_files:
		var license_path = licenses_path + '/' + license_file_name
		var license_content = fs.read_file(license_path)
		
		var label = Label.new()
		label.autowrap = true
		label.text = license_content
		add_to_scroll_container(label)
		
		add_to_scroll_container(HSeparator.new())
