extends Control

@onready var popularityBar = $Popularity
@onready var scoreText = $Score

func _process(delta):
	popularityBar.value = ScoreSaver.popularity
	scoreText.text = str(snapped(ScoreSaver.score, 0.01))
