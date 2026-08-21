extends CharacterBody3D

var startPosition : Transform3D
var playerCoins = 0
const SPEED = 5.0
var sprintSpeed = 0.0
const JUMP_VELOCITY = 9
var xform : Transform3D

@export var winCoins := 0
#@export var hud : CanvasLayer

#For Character rotation
var is_dragging: bool = false
@export var mouse_sensitivity: float = 0.007

#define a new signal when the coin amount changes
#signal coins_changed(new_amount: int)


#Make Character rotate when holding right click - in turn, camera should follow.
#Rotation should be y axis (left and right) and x axis (up and down)
func _input(event: InputEvent) -> void:
	# Check if left mouse button is clicked/released
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			is_dragging = event.pressed
			if is_dragging:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			else: Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			
	# Rotate character when dragging the mouse
	elif event is InputEventMouseMotion and is_dragging:
		rotate_y(-event.relative.x * mouse_sensitivity)
	if event.is_action_released("MB2"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	#	print(event.as_text())



func _ready() -> void:
	startPosition = global_transform
	
	#Set Master.playerCoins to 0 so you can restart the level fresh instead of with winCoins
	Master.playerCoins = 0



func _sprint() -> void: 
	pass

func _physics_process(delta: float) -> void:
	
	# Add the gravity.
	if not is_on_floor():
		velocity += 2.5*get_gravity() * delta

	# Add sprint speed and modifier 
	if Input.is_action_pressed("sprint"):
		sprintSpeed = 5
	else: sprintSpeed = 0
	
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction : Vector3 = ($CameraController.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	#Rotate the character mesh so it is looking at the direction of the camera
	if input_dir != Vector2(0,0):
		rotation.y = $CameraController.rotation.y - input_dir.angle() - PI/2
	if direction:
		velocity.x = direction.x * (SPEED + sprintSpeed)
		velocity.z = direction.z * (SPEED + sprintSpeed)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	# Rotate char to align with floor
	if is_on_floor():
		align_with_floor($Ray.get_collision_normal())
		global_transform = global_transform.interpolate_with(xform,0.5)
	elif not is_on_floor():
		align_with_floor(Vector3.UP)
		global_transform = global_transform.interpolate_with(xform,0.5)


	
	
	


	move_and_slide()
	
	#Make CameraController match the position of the character
	#the dollar sign lets you access a node within the root node by name
	# reference the position of the CameraController and set it equal to the
	# position of the root node, which needs no call 
	# MainCharacter.position == position. 
	# lerp(from,to,how fast) - Using delta should be considered as it would make 
	# the follow speed the same on all machines. Consider clamp in 3rd arg. 
	$CameraController.position = lerp($CameraController.position,position,clamp(60*0.35*delta,0.15,1))
	#Make CameraController match the rotation of the character
	#$CameraController.rotation.y = lerp($CameraController.rotation.y,rotation.y,0.35)
	
	# Rotate camera left / right
	if Input.is_action_just_pressed("ui_left"):
		$CameraController.rotate_y(deg_to_rad(30))
	if Input.is_action_just_pressed("ui_right"):
		$CameraController.rotate_y(deg_to_rad(-30))
	


func align_with_floor(floor_normal):
	xform = global_transform
	xform.basis.y = floor_normal
	xform.basis.x = -xform.basis.z.cross(floor_normal)
	xform.basis = xform.basis.orthonormalized()
	#print(floor_normal)
	

#adds 1 coin to Master.playerCoins
#func add_coin():
#	Master.playerCoins += 1
#	hud.get_node("CoinCount").text = str(Master.playerCoins)
#	if Master.playerCoins >= winCoins:
#		get_tree().change_scene_to_file("res://borncg.tscn")
#	coins_changed.emit(Master.playerCoins)

#function to reset Char to starting position with 0 speed.
func reset_position():
	global_transform = startPosition
	velocity = Vector3.ZERO 

#Safety net to prevent infinite falling through world. 
func _on_death_barrier_body_entered(_body : Node3D) -> void:
	if _body == self: #consider adding collision layers and masks
		reset_position()
	
