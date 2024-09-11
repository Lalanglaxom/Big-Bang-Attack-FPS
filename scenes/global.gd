extends Node

@onready var root = $"."
var projectile_path: Vector3
var enemy_remain

var ui: Control
var endless: bool

signal on_hit(damage)
signal on_enemy_hit(body, damage)
signal on_enemy_die()
signal on_pause()

func _unhandled_input(event):
	if event.is_action_pressed("screenshot") :
		var capture = get_viewport().get_texture().get_image()
		var _time = Time.get_datetime_string_from_system()
		var filename = "user://Screenshot-{0}.png".format({"0":_time})
		capture.save_png(filename)
		print("AAA")
