extends KinematicBody

export(bool) var burro := false
export(bool) var view_balde := false
export(bool) var pickaxe_speak := false
export(bool) var can_attack := false
export(bool) var can_pick_items := false
export(bool) var has_pickaxe := false
export(int) var pickaxe_life := 1
var pickaxe_life_init := pickaxe_life
export(bool) var check_sound_time := false
export(bool) var can_pause := true
export(bool) var paused := false
export(bool) var to_play := false
export(String) var current_day := "Dia 1"
export(int, 0, 8) var bricks := 8
var initial_bricks := bricks
export(String) var next_scene
var grande_queda := false

export(NodePath) var radio := "."
var pica_reta := "CameraPivot/Camera/ItemPos/PicaReta"
var day_label := "CameraPivot/Camera/Fade/DayLabel"
var camera_pivot := "CameraPivot"
var camera := "CameraPivot/Camera"
var item_pos := "CameraPivot/Camera/ItemPos"
var pause_control := "CameraPivot/Camera/Pause"

export(Vector3) var velocity := Vector3()
var y_velocity = velocity.y
export(float) var speed := 12.0
export(float) var acceleration := 5.0
export(float) var deceleration := 11.0
export(float) var air_acceleration := 2.5
export(float) var gravity      := 9.8 * 3
export(bool ) var can_jump     := false
export(float) var jump_force   := 9.5


# CAMERA
export(float, 0.01, 1) var mouse_sensitivity := 0.2
export(float, -90,  0) var min_angle := -90
export(float,   0, 90) var max_angle :=  90

# HINTS
onready var hint_tacar_tijolo := $CameraPivot/Camera/Hints/TacarTijolo
onready var hint_pick_brick   := $CameraPivot/Camera/Hints/PickBrick
onready var hint_jump         := $CameraPivot/Camera/Hints/Jump

# BRICK
onready var brick_picked := $"."

# SOME VARS #
var walking := false

func vars():
	initial_bricks    = bricks
	pickaxe_life_init = pickaxe_life
	pass

var configs := {}
func config_load():
	var config_file = File.new()
	if !config_file.file_exists("res://config.json"):
		return
	
	config_file.open("res://config.json", File.READ)
	configs = parse_json(config_file.get_as_text())
	config_file.close()
	mouse_sensitivity = configs["mouse_sensitivity"]
#	print(OS.get_user_data_dir())
	pass

func _ready():
	get_node(day_label).text = current_day
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_node(pause_control).visible = paused
	
	config_load()
	vars()
#	print(pickaxe_life_init)
	pass

func _process(delta):
	if !to_play:
		return
	
	if Input.is_action_just_pressed("ui_cancel") && can_pause:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			paused = true
		elif Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			paused = false
	get_node(pause_control).visible = paused
	
	pass

func _input(event):
	if !to_play || paused:
		return
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		get_node(camera_pivot).rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))
		get_node(camera_pivot).rotation_degrees.x = clamp(
			get_node(camera_pivot).rotation_degrees.x, min_angle, max_angle)
	
	pass

func _physics_process(delta):
	if !to_play || paused:
		return
	var _direction := Vector3()
	if Input.is_action_pressed("move_forward"):
		_direction -= transform.basis.z
	if Input.is_action_pressed("move_backward"):
		_direction += transform.basis.z
	if Input.is_action_pressed("move_left"):
		_direction -= transform.basis.x
	if Input.is_action_pressed("move_right"):
		_direction += transform.basis.x
	_direction = _direction.normalized()
	velocity.y = 0
	var _accel = ((acceleration if _direction.length() != 0 else deceleration)
		if is_on_floor() else (air_acceleration if _direction.length() > 0 else 0)
	)
	if $GroundCheck.is_colliding() && $GroundCheck.get_collider().is_in_group("Slope"):
		_accel *= 4
	velocity = velocity.linear_interpolate(_direction * speed, _accel * delta)
	velocity = move_and_slide(Vector3(velocity.x, 0, velocity.z), Vector3.UP, true, 4, PI/4, true)
	walking = true if _direction.length() != 0 else false
	
	# Y
	y_velocity = move_and_slide(Vector3(0, y_velocity, 0), Vector3.UP, true, 4, PI/4, true).y
	if !is_on_floor():
		y_velocity -= gravity * delta
	else:
		if $GroundCheck.is_colliding() && $GroundCheck.get_collider().is_in_group("Slope"):
			y_velocity = -gravity
		else:
			y_velocity = -0.1
	# JUMP
	if is_on_floor():
		if Input.is_action_just_pressed("jump") && can_jump:
			y_velocity = jump_force
	if !is_on_floor() && !grande_queda:
		if y_velocity < -26:
#			print("Putz")
			grande_queda = true
	
	
	
	# RESET CROSSHAIR
	$CameraPivot/Camera/Crosshair/C.position.x = int(get_viewport().size.x / 2)
	$CameraPivot/Camera/Crosshair/C.position.y = int(get_viewport().size.y / 2)
	$CameraPivot/Camera/Crosshair.visible = false
	if can_pick_items:
		if has_pickaxe && brick_picked == $".":
			if ($CameraPivot/Camera/RayRock.is_colliding()
			&&  $CameraPivot/Camera/RayRock.get_collider().is_in_group("Rock")):
				$CameraPivot/Camera/Crosshair.visible = true
		
		# PICK ITEM
		# === Pegar a Pica Reta === #
		if (brick_picked == $"." && $CameraPivot/Camera/RayBrick.is_colliding()
		&&  $CameraPivot/Camera/RayBrick.get_collider().is_in_group("PicaReta")
		&&  !has_pickaxe):
			$CameraPivot/Camera/Crosshair.visible = true
			if Input.is_action_just_pressed("fire"):
				$CameraPivot/Camera/RayBrick.get_collider().queue_free()
				has_pickaxe = true
				get_node(pica_reta).state_machine.travel("PickUp")
		if (brick_picked == $"." && $CameraPivot/Camera/RayBrick.is_colliding()
		&&  $CameraPivot/Camera/RayBrick.get_collider().is_in_group("Brick")):
			$CameraPivot/Camera/Crosshair.visible = (
				true if $CameraPivot/Camera/RayBrick.get_collider().pickable else false)
			if (Input.is_action_just_pressed("fire")):
				if ($CameraPivot/Camera/RayBrick.get_collider().pickable):
					brick_picked = $CameraPivot/Camera/RayBrick.get_collider()
					brick_picked.get_node("Coll").disabled = true
					brick_picked.scale = Vector3(.1, .1, .1)
					brick_picked.rotation_degrees = Vector3.ZERO
		if brick_picked != $".":
			if ($CameraPivot/Camera/RayBrick.is_colliding()):
				if ($CameraPivot/Camera/RayBrick.get_collider().is_in_group("BrickPos")
				&&  !brick_picked.is_in_group("TacaOTijolo")):
					if $CameraPivot/Camera/RayBrick.get_collider().pickable:
						$CameraPivot/Camera/Crosshair.visible = true
						if brick_picked.painted == true:
							if (Input.is_action_just_pressed("fire")):
								brick_picked.global_transform.origin = (
									$CameraPivot/Camera/RayBrick.get_collider().global_transform.origin)
								brick_picked.scale = Vector3(1, 1, 1)
								brick_picked.rotation_degrees = (
									$CameraPivot/Camera/RayBrick.get_collider().rotation_degrees)
								brick_picked.pickable = false
								brick_picked.get_node("Coll").disabled = false
								$CameraPivot/Camera/RayBrick.get_collider().queue_free()
								brick_picked = $"."
								bricks -= 1
								get_node(pica_reta).state_machine.travel("PickUp")
					if brick_picked != $"." && brick_picked.painted == false && !burro: # BURRO
						$CameraPivot/Camera/Crosshair.visible = true
						if Input.is_action_just_pressed("fire"):
							$Burro.play(0.0)
							burro = true
				if ($CameraPivot/Camera/RayBrick.get_collider().is_in_group("Bucket")):
					if brick_picked.painted == false:
						if !view_balde: # VIEW BALDE
							$Balde.play(0.0)
							view_balde = true
							$Burro.stop()
#							burro = true
						$CameraPivot/Camera/Crosshair.visible = true
						if Input.is_action_just_pressed("fire") && view_balde:
							brick_picked.set_painted()
			if (!$CameraPivot/Camera/RayBrick.is_colliding() && brick_picked.is_in_group("TacaOTijolo")):
				if Input.is_action_just_pressed("fire"):
					brick_picked.global_transform.basis = $CameraPivot/Camera/ItemPos.global_transform.basis
					brick_picked.taca = Vector3.ONE
					brick_picked.scale = Vector3.ONE
					bricks -= 1
					brick_picked = $"."
		elif bricks <= 0:
			if ($CameraPivot/Camera/RayBrick.is_colliding()
			&&  $CameraPivot/Camera/RayBrick.get_collider().is_in_group("Bed")):
				$CameraPivot/Camera/Crosshair.visible = true
				if Input.is_action_just_pressed("fire"):
					$CameraPivot/Camera/Fade/Anim.play("FadeIn")
					if radio != ".":
						get_node(radio).anim.play("FadeOut")
	
	if brick_picked != $".":
		# A POSIÇÃO DO TIJOLO NA MÃO
		brick_picked.global_transform.origin = get_node(item_pos).global_transform.origin
	
	pass

func _on_Anim_animation_finished(anim_name):
	if !to_play:
		if anim_name == "FadeIn":
			get_tree().change_scene(next_scene)
	
	pass










