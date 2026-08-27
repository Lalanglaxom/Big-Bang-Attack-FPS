extends Control


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_play_button_up():
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_menu_button_up():
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
