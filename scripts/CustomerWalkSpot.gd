extends Area3D

class_name TargetSpot

var isSomeoneSat = false
@onready var parent = $".."
var customer

func _on_body_entered(body):
	if isSomeoneSat == true:
		body = body as Customer
		if !body.outraged or body.target != self.get_child(0).get_global_position():
			body.updateTargetLocation(body.allTargets.get_child(body.rng.randi_range(0, body.allTargets.get_child_count() - 1)).get_child(0).get_global_position())
		return
	
	body = body as Customer
	if body.outraged or body.target != self.get_child(0).get_global_position():
		return
	isSomeoneSat = true
	parent.customer = body as Customer
	customer = body as Customer
	print("SAT")
	
func _on_body_exited(body):
	if (body as Customer) == (customer as Customer):
		customer = null
		isSomeoneSat = false
	
func _process(delta):
	parent.customerSat = isSomeoneSat


