extends Node

@onready var root = $"."

signal on_parry_pressed()
signal on_parry_success()
signal on_parry_failed()

func _unhandled_input(event):
	if event.is_action_pressed("screenshot") :
		var capture = get_viewport().get_texture().get_image()
		var _time = Time.get_datetime_string_from_system()
		var filename = "user://Screenshot-{0}.png".format({"0":_time})
		capture.save_png(filename)
		print("AAA")
