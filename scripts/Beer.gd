extends RigidBody3D

class_name Beer

var grabbed = false
var fillMeter = 0
var readyToGive = false

@onready var beerStages = [$CollisionShape3D/Beer2/Water, $CollisionShape3D/Beer2/Water_001, $CollisionShape3D/Beer2/Water_002,
$CollisionShape3D/Beer2/Water_003, $CollisionShape3D/Beer2/Water_004, $CollisionShape3D/Beer2/Water_005, $CollisionShape3D/Beer2/Water_006,
$CollisionShape3D/Beer2/Water_007, $CollisionShape3D/Beer2/Water_008, $CollisionShape3D/Beer2/Water_009]

func _process(delta):
	if(fillMeter >= 1):
		readyToGive = true
	else:
		readyToGive = false
		
	for stage in beerStages:
		stage.visible = false
	
	if fillMeter <= 0.1:
		beerStages[0].visible = true
	if fillMeter > 0.1 and fillMeter <= 0.2:
		beerStages[1].visible = true
	if fillMeter > 0.2 and fillMeter <= 0.3:
		beerStages[2].visible = true
	if fillMeter > 0.3 and fillMeter <= 0.4:
		beerStages[3].visible = true
	if fillMeter > 0.4 and fillMeter <= 0.5:
		beerStages[4].visible = true
	if fillMeter > 0.5 and fillMeter <= 0.6:
		beerStages[5].visible = true
	if fillMeter > 0.6 and fillMeter <= 0.7:
		beerStages[6].visible = true
	if fillMeter > 0.7 and fillMeter <= 0.8:
		beerStages[7].visible = true
	if fillMeter > 0.8 and fillMeter <= 0.9:
		beerStages[8].visible = true
	if fillMeter > 0.9 and fillMeter <= 1:
		beerStages[9].visible = true

func addBeer(delta):
	fillMeter += delta / 3
	fillMeter = clamp(fillMeter, 0.0, 1.0)
