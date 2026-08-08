extends Control


func _on_play_button_up():
	Global.endless = false
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_quit_button_up():
	get_tree().quit()


func _on_check_button_toggled(toggled_on):
	Global.endless = !Global.endless
	

func _on_check_button_button_up():
	Global.endless = true
	get_tree().change_scene_to_file("res://scenes/game.tscn")
