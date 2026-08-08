extends Node3D
@onready var ui = $"../UI"

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		elif Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			
		if get_tree().paused == false:
			ui.show()
			get_tree().paused = true
		else:
			ui.hide()
			get_tree().paused = false
			print(get_tree().paused)
