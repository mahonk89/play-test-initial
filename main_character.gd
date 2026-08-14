extends CharacterBody3D

var playerCoins = 0
const SPEED = 5.0
const JUMP_VELOCITY = 4.5

#define a new signal when the coin amount changes
signal coins_changed(new_amount: int)


func _physics_process(delta: float) -> void:

	
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
	#Make CameraController match the position of the character
	#the dollar sign lets you access a node within the root node by name
	# reference the position of the CameraController and set it equal to the
	# position of the root node, which needs no call 
	# MainCharacter.position == position. 
	# lerp(from,to,how fast) - Using delta should be considered as it would make 
	# the follow speed the same on all machines. Consider clamp in 3rd arg. 
	$CameraController.position = lerp($CameraController.position,position,clamp(60*0.15*delta,0.15,1))

# Print the input event to Output (key press, mouse buttons/movement)
#func _input(event):
	#print(event.as_text())
	

#adds 1 coin to playerCoins
func add_coin():
	playerCoins += 1
	coins_changed.emit(playerCoins)
