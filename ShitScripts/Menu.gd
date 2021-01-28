extends Control

var next_scene := ""

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	OS.min_window_size.x = ProjectSettings.get("display/window/size/width")
	OS.min_window_size.y = ProjectSettings.get("display/window/size/height")
	
	pass

func _on_Start_pressed():
	$Fade/AnimPlayer.play("FadeIn")
	next_scene = $Buttons/Start.next_scene
	pass

func _on_Credits_pressed():
	$Fade/AnimPlayer.play("FadeIn")
	next_scene = $Buttons/Credits.next_scene
	pass


func _on_Config_pressed():
	$Fade/AnimPlayer.play("FadeIn")
	next_scene = $Buttons/Config.next_scene
	
	pass

func _on_AnimPlayer_animation_finished(anim_name):
	if anim_name == "FadeIn":
		get_tree().change_scene(next_scene)
	
	pass

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	
	pass







