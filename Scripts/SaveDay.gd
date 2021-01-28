extends Spatial

export(int) var day := 1

func _ready():
	var _config = File.new()
	if !_config.file_exists("res://config.json"):
		return
	_config.open("res://config.json", File.READ_WRITE)
	var _configs = parse_json(_config.get_as_text())
	if _configs["levels"] < day:
		_configs["levels"] = day
	_config.store_line(to_json(_configs))
	_config.close()
	pass
