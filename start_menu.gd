extends CenterContainer

@onready var start_button = %StartButton

func _ready():
	RenderingServer.set_default_clear_color(Color.BLACK)
	start_button.grab_focus()
	
func _on_start_pressed():
	await LevelTransition.fade_to_black()
	get_tree().change_scene_to_file("res://level_one.tscn")
	LevelTransition.fade_from_black()
func _on_quit_pressed():
	get_tree().quit() # Replace with function body.


