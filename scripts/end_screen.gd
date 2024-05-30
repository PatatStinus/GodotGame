extends Control

@onready var scoreText = $Label

func _on_retry_pressed():
	ScoreSaver.score = 0
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_quit_pressed():
	get_tree().quit()
	
func _ready():
	scoreText.text = "Your Score: " + str(ScoreSaver.score) 
