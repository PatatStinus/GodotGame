extends Area3D

@onready var beerPlacement = $Marker3D
var beerInSpot
var customerSat = false
var customer

func body_entered(body):
	#body.gravity_scale = 0
	if beerInSpot == null and customerSat == true:
		beerInSpot = body as Beer
		if beerInSpot.readyToGive:
			beerInSpot.grabbed = false
			beerInSpot.linear_velocity = Vector3.ZERO
			beerInSpot.angular_velocity = Vector3.ZERO
			beerInSpot.rotation = Vector3.ZERO
			beerInSpot.global_position = beerPlacement.global_position
		else:
			beerInSpot = null

func body_exited(body):
	#body.gravity_scale = 1
	if body as Beer == beerInSpot:
		beerInSpot = null
		
func _process(delta):
	if beerInSpot != null:
		beerInSpot.fillMeter -= delta / 10
		customer.drinking = true
		if beerInSpot.fillMeter <= 0:
			beerInSpot.fillMeter = 0
			beerInSpot = null
			customer.drinking = false
			customer.drunkness += 1
			customer.drunkness = clamp(customer.drunkness, 1, 10)
			get_tree().call_group("GameManager", "changePopularity", 5)
			customer.updateTargetLocation(customer.allTargets.get_child(customer.rng.randi_range(0, customer.allTargets.get_child_count() - 1)).get_child(0).get_global_position())
