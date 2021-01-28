extends Button

export(NodePath) var fade_anim
export(NodePath) var sensi_slider
export(NodePath) var fullscreen_check

export(String) var next_scene

const config_path := "res://config.json"

#func _ready():
#	print(str(OS.get_user_data_dir()))

func _pressed():
	get_node(fade_anim).play("FadeIn")
	
	pass

func _on_Anim_animation_finished(anim_name):
	if anim_name == "FadeIn":
		var save_settings = File.new()
		save_settings.open(config_path, File.READ_WRITE)
		var tdict = parse_json(save_settings.get_as_text())
		save_settings.store_line(to_json(save(tdict)))
		save_settings.close()
		get_tree().change_scene(next_scene)
	
	pass

func save(_dict):
	return {
		"mouse_sensitivity": get_node(sensi_slider).value,
		"fullscreen": get_node(fullscreen_check).pressed,
		"levels": _dict["levels"]
	}
	
	pass
