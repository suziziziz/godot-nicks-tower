extends StaticBody

export(bool) var pickable = true
export(bool) var painted = true
export(Vector3) var taca := Vector3()

var time := 0.0
var time_max := 2.5

func _process(delta):
	if taca.length() > 0:
		translation -= transform.basis.z.normalized() * 80 * delta
		if time >= time_max:
			queue_free()
		time += delta
	
	pass
