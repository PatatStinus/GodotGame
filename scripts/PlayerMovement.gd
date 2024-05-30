extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.003

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var head = $Head
@onready var camera = $Head/Camera3D

@onready var raycast = $Head/Camera3D/RayCast3D
@onready var grabPos = $Head/Camera3D/Marker3D

# Head bobs
const BOB_FREQ = 2.0
const BOB_AMP = 0.08
var t_bob = 0.0

var push_force = .4

var heldItem
var pullForce = 4

func pick_up_item():
	var collider = raycast.get_collider()
	if collider != null and collider is Beer:
		heldItem = collider as Beer
		heldItem.grabbed = true
		
	if collider != null and collider is Customer:
		heldItem = collider as Customer
		
func punch():
	var collider = raycast.get_collider()
	if collider != null and collider is Customer:
		var hitCustomer = collider as Customer
		hitCustomer.kill()
		
func _input(event):
	if Input.is_action_just_pressed("interact"):
		pick_up_item()
	if Input.is_action_just_released("interact") and heldItem != null or heldItem is Beer and heldItem.grabbed == false:
		if heldItem is Beer:
			heldItem.grabbed = false
		heldItem = null
	if Input.is_action_just_pressed("punch"):
		punch()
	if Input.is_action_just_pressed("exitgame"):
		get_tree().quit()

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))
		
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = lerp(velocity.x, direction.x * SPEED, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * SPEED, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * SPEED, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * SPEED, delta * 3.0)
		

	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	move_and_slide()
	
	# Push rigidbodies
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody3D:
			c.get_collider().apply_central_impulse(-c.get_normal() * push_force)
			
	if heldItem != null:
		var a = heldItem.global_transform.origin
		var b = grabPos.global_transform.origin
		if heldItem is Beer and heldItem.grabbed == true:
			heldItem.set_linear_velocity((b - a) * pullForce)
		if heldItem is Customer and heldItem.dead == true:
			for i in 14:
				heldItem.get_child(0).get_child(0).get_child(0).get_child(i).global_position = b
	
func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = sin(time * BOB_FREQ / 2) * BOB_AMP
	return pos
