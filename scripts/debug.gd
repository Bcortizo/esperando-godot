extends Node

func _unhandled_input(event):
	if event.is_action_pressed("reset_game"):
		get_tree().reload_current_scene()
