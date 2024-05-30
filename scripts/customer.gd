extends CharacterBody3D

class_name Customer

@onready var allTargets = get_parent().get_parent().get_child(0)
@onready var fightTargets = get_parent().get_parent().get_child(2)
var target : Vector3
var rng = RandomNumberGenerator.new()

@onready var agent = $NavigationAgent3D

@onready var speed : float = rng.randf_range(3.0, 5.0)

@onready var label = $CollisionShape3D/Label3D
@onready var animator = $Irish_Beer_Drinker/AnimationTree
@onready var ragdoll =  $Irish_Beer_Drinker/metarig/Skeleton3D as SkeletonCustomer
@onready var spine = $"Irish_Beer_Drinker/metarig/Skeleton3D/Physical Bone spine_001"
@onready var collider = $CollisionShape3D
@onready var calmAudio = $CalmAudio
@onready var fightAudio = $FightAudio
const angryPrompts = ["Calm", "Displeased", "Frustrated", "Angry", "OUTRAGED"]
var angerPercentage : float
var drunkness = 1.0
var drinking = false

var oppCust
var outraged = false
var fighting = false
var dead

func _ready():
	await get_tree().create_timer(5).timeout
	updateTargetLocation(allTargets.get_child(rng.randi_range(0, allTargets.get_child_count() - 1)).get_child(0).get_global_position())
	
func _process(delta):
	if dead:
		collider.global_position = spine.global_position
		for i in self.get_parent().get_child_count():
			if collider.global_position.distance_to(self.get_parent().get_child(i).get_global_position()) < 5.0 and collider.global_position.distance_to(self.get_parent().get_child(i).get_global_position()) != 0:
				var closeCustomer = self.get_parent().get_child(i) as Customer
				closeCustomer.angerPercentage += (delta * closeCustomer.drunkness)
		return
	
	if !drinking:
		angerPercentage += (delta * drunkness)
	else:
		angerPercentage -= (delta * drunkness)
	angerPercentage = clamp(angerPercentage, 0, 100)
	outraged = false
	var promptIndex = 0
	if angerPercentage <= 25:
		promptIndex = 0
	if angerPercentage > 25 and angerPercentage <= 50:
		promptIndex = 1
	if angerPercentage > 50 and angerPercentage <= 75:
		promptIndex = 2
	if angerPercentage > 75 and angerPercentage < 100:
		promptIndex = 3
	if angerPercentage == 100:
		promptIndex = 4
		outraged = true
		
	if outraged and !fighting:
		lookForFight()
	
	label.text = angryPrompts[promptIndex]
	var Colors = [Color.CHARTREUSE, Color.DARK_ORANGE, Color.DARK_RED]
	label.modulate = multi_colour_lerp(Colors, angerPercentage / 100)
	
	if outraged:
		for i in self.get_parent().get_child_count():
			if position.distance_to(self.get_parent().get_child(i).get_global_position()) < 5.0 and position.distance_to(self.get_parent().get_child(i).get_global_position()) != 0:
				var closeCustomer = self.get_parent().get_child(i) as Customer
				closeCustomer.angerPercentage += (delta * closeCustomer.drunkness)
	
	animator.set("parameters/conditions/Idle", velocity.length() <= 1)
	animator.set("parameters/conditions/Walk", velocity.length() > 1)
	animator.set("parameters/conditions/Fight", false)
	
	if fighting:
		get_tree().call_group("GameManager", "changePopularity", -(delta / 6))
		animator.set("parameters/conditions/Idle", false)
		animator.set("parameters/conditions/Walk", velocity.length() > 1)
		animator.set("parameters/conditions/Fight", velocity.length() <= 1)
		if velocity.length() <= 1 and oppCust.global_position != global_position:
			look_at(oppCust.global_position)
		
func _physics_process(delta):
	if dead:
		return
	
	look_at(target)
	rotation.x = 0
	rotation.z = 0
	
	if position.distance_to(target) > 0.1:
		var curLoc = global_transform.origin
		var nextLoc = agent.get_next_path_position()
		var newVel = (nextLoc - curLoc).normalized() * speed
		velocity  = newVel
		move_and_slide()
		
func lookForFight():
	fighting = true
	calmAudio.stop()
	fightAudio.play()
	oppCust = self.get_parent().get_child(rng.randi_range(0, self.get_parent().get_child_count() - 1)) as Customer
	var index = 0
	while oppCust == (self as Customer) or oppCust.fighting or oppCust.dead:
		oppCust = self.get_parent().get_child(index) as Customer
		index += 1
		if index == self.get_parent().get_child_count():
			return
	
	oppCust.fighting = true
	oppCust.angerPercentage = 100
	oppCust.calmAudio.stop()
	oppCust.fightAudio.play()
	var fightTarget = fightTargets.get_child(rng.randi_range(0, fightTargets.get_child_count() - 1))
	oppCust.updateTargetLocation(fightTarget.get_child(0).get_global_position())
	updateTargetLocation(fightTarget.get_child(1).get_global_position())
	oppCust.oppCust = self as Customer

func updateTargetLocation(targetSet):
	target = targetSet
	agent.set_target_position(target)
	
func multi_colour_lerp(colours: Array, t: float) -> Color:
	t = clamp(t, 0, 1)

	var delta: float = 1.0 / (colours.size() - 1)
	var start_index: int = int(t / delta)

	if start_index == colours.size() - 1:
		return colours[colours.size() - 1]

	var local_t: float = fmod(t, delta) / delta

	return colours[start_index].lerp(colours[start_index + 1], local_t)


func kill():
	#Knock Out Customer
	if !outraged:
		angerPercentage += 25
	else:
		if dead:
			return
		
		dead = true
		label.text = "DEAD"
		angerPercentage = 0
		oppCust.updateTargetLocation(allTargets.get_child(rng.randi_range(0, allTargets.get_child_count() - 1)).get_child(0).get_global_position())
		oppCust.fighting = false
		oppCust.angerPercentage = 50
		animator.set("parameters/conditions/Idle", false)
		animator.set("parameters/conditions/Walk", false)
		animator.set("parameters/conditions/Fight", false)
		ragdoll.startRagDoll()
		get_tree().call_group("GameManager", "customerDied")
		fightAudio.stop()
		oppCust.fightAudio.stop()
		oppCust.calmAudio.play()
		print("customer killed :(")
