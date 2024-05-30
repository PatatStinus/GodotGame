extends Area3D

var allBeersInRange = []

func body_entered(body):
	allBeersInRange.append(body as Beer)
func body_exited(body):
	allBeersInRange.erase(body as Beer)
	
func _process(delta):
		for beer in allBeersInRange:
			beer.addBeer(delta)
