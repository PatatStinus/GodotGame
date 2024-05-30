extends Node3D

signal change_popularity(changes: float)

var popularity = 30
var score = 0
var customersSpawned = 1

const CUSTOMER = preload("res://scenes/customer.tscn")
@onready var parentCustomer = $BeerSpots/Customers
@onready var customerSpawnPoint = $CustomerSpawn
var time = 0

func _process(delta):
	time += delta
	time = clamp(time, 0, 500)
	
	score += popularity * delta
	popularity -= delta * (time / 500)
	
	ScoreSaver.score = score
	ScoreSaver.popularity = popularity
	
	var amountOfCustomers = floor(popularity / 14.28) + 1
	
	if amountOfCustomers > customersSpawned:
		var customer = CUSTOMER.instantiate()
		parentCustomer.add_child(customer)
		customer.global_position = customerSpawnPoint.global_position
		customersSpawned += 1
	
	
func changePopularity(changes):
	popularity += changes
	popularity = clamp(popularity, 0, 100)
	if(popularity == 0):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().change_scene_to_file("res://scenes/end_screen.tscn")
		
func customerDied():
	customersSpawned -= 1
