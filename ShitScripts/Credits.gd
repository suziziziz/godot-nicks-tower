extends Control

export(NodePath) var return_button

var next_scene := ""

func _on_Return_pressed():
	next_scene = get_node(return_button).next_scene
	$Fade/Anim.play("FadeIn")
	pass

func _on_Anim_animation_finished(anim_name):
	if anim_name == "FadeIn":
		get_tree().change_scene(next_scene)
	
	pass




