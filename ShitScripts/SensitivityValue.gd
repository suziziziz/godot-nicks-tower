extends Label

export(NodePath) var slider

func _process(delta):
	text = str(get_node(slider).value)
	
	pass
