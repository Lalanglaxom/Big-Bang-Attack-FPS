extends Node

@onready var root = $"."

const COMBAT_DEV = preload("uid://cdp5r2vqaqf5s")
const GYM_DEV = preload("uid://ceyfa72kjjp4e")


func _unhandled_input(event):
	#if event.is_action_pressed("screenshot") :
		#var capture = get_viewport().get_texture().get_image()
		#var _time = Time.get_datetime_string_from_system()
		#var filename = "user://Screenshot-{0}.png".format({"0":_time})
		#capture.save_png(filename)
		#print("AAA")
		
	if event.is_action_pressed("combat_scene") :
		get_tree().change_scene_to_packed(COMBAT_DEV)
	if event.is_action_pressed("gym_dev_scene") :
		get_tree().change_scene_to_packed(GYM_DEV)
		
	pass
