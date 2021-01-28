extends Node2D

const keys := {
	"mouse_sensitivity": 0.15,
	"fullscreen": false,
	"levels": 1,
}

func _ready():
	
	
	var config_file = File.new()
	if !config_file.file_exists("res://config.json"):
		config_file.open("res://config.json", File.WRITE)
		config_file.store_line(to_json(keys))
		config_file.close()
	
	config_file.open("res://config.json", File.READ)
	var _configs = parse_json(config_file.get_as_text())
	OS.window_fullscreen = (_configs["fullscreen"] if
		OS.window_fullscreen != _configs["fullscreen"] else OS.window_fullscreen)
	config_file.close()
#	print(str(OS.get_user_data_dir()))
	pass

