extends CharacterBody3D

var startPosition : Vector3

# Character Attribute Variables
@export var speed := 5
@export var sprintSpeed := 5
@export var jump_velocity := 9
@export var maxStamina := 80
@export var stamRegen := 10.0
@export var stamEffic := 40.0

# vars for _physics_process()
var sprintMod : int
var stamina= maxStamina

#For Character rotation
var is_dragging: bool = false
@export var mouse_sensitivity: float = 0.007

#define new signals
signal coins_changed(new_amount: int) # When Master.playerCoins changes
signal stamina_changes(current_stam: float) # Current stamina value


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
		
	#print(event.as_text())

func _ready() -> void:
	startPosition = global_position #This does not reset player rotation


func _physics_process(delta: float) -> void:
	
	# Add the gravity.
	if not is_on_floor():
		velocity += 2.5*get_gravity() * delta

	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * (speed + sprintMod)
		velocity.z = direction.z * (speed + sprintMod)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	# Handle sprint & stamina
	#### SPRINT STAYS AT 5 EVEN IF STAMINA IS 0 - FIND PAUSE/DELAY
	## If I hold shift, sprintMod = 5 (sprintSpeed) even if stamina gets to -5 because 
	# I am STILL HOLDING SHIFT - therefore it never left the if statement because all conditions
	# were met, and now the TRUE expressions that are running change the CONDITion to no longer be
	# true. However, it isn't checking the conditions any longer, it's simply running the expressions.
	# CONSIDER A WHILE LOOP e.g. while stamina > 0, .... 
	if Input.is_action_pressed("sprint"): #if holding sprint button
		if input_dir != Vector2.ZERO and stamina > 0: #if moving and you have stamina:
			sprintMod = sprintSpeed #set sprint mod in movement handle to sprintSpeed
			stamina -= stamEffic * delta #reduce stamina by a stamEffic[iency] factor when sprinting
			stamina_changes.emit(stamina) # send to UI (node) via connection current stamina
			if stamina <= 0.2:
				stamina = -5
		elif input_dir == Vector2.ZERO and stamina < maxStamina: #if stamina is low and NOT moving (but holding shift) then
			sprintMod = 0
			stamina += stamRegen * delta # add stamina by a stamRegen factor
			stamina_changes.emit(stamina) # send to UI (node) via connection current stamina
	else: # if NOT holding sprint button
		sprintMod = 0 # set sprint speed addition to 0
		if stamina < maxStamina: # and if your stamina is low, 
			stamina += stamRegen * delta # start regenerating by a factor of stamRegen
			stamina_changes.emit(stamina) # send to UI (node) via connection current stamina
	
	#print(roundi(stamina), " stamina remaining // speed at ",speed+sprintMod)
	print("Holding shift: ",Input.is_action_pressed("sprint"))
	print("Moving WITH Stamina: ",bool(input_dir != Vector2.ZERO and stamina > 0))
	print("Stamina: ",roundf(stamina),", sprint speed: ",sprintMod)
	
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
	$CameraController.rotation.y = rotation.y
	
	# Rotate camera left / right



#adds 1 coin to Master.playerCoins
func add_coin():
	Master.playerCoins += 1
	coins_changed.emit(Master.playerCoins)
	


#function to reset Char to starting position with 0 speed.
func reset_position():
	global_position = startPosition # this does not reset player rotation
	velocity = Vector3.ZERO 

#Safety net to prevent infinite falling through world. 
func _on_death_barrier_body_entered(_body : Node3D) -> void:
	if _body == self:
		reset_position() # player rotation is not reset
