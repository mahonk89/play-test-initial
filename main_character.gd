extends CharacterBody3D

var startPosition : Transform3D

# Character Attribute Variables
@export var health := 2
@export var speed := 5
@export var sprintSpeed := 5
@export var jump_velocity := 9
@export var maxStamina := 80
@export var stamRegen := 10.0
@export var stamEffic := 25.0

# vars for _physics_process()
var sprintMod : int = 0
var stamina = maxStamina
var canSprint := true

# vars for alpha scene (level specific)
@onready var level = owner
@onready var winCoins = level.coins_to_win

# Other variablees
@onready var dir : Vector3
var dead := false
var collision_masks : Array = [1,3,4,5,10]
var masks = collision_masks.size()

#For Character rotation
var is_dragging: bool = false
## X-axis mouse sensitivity (up/down direction). To adjust the y-axis (left/right movement),
## go to Main Character / Mouse Sensitivity. 
@export var mouse_sensitivity: float = 0.007

#define new signals
signal coins_changed(new_amount: int) # When Master.playerCoins changes
signal stamina_changes(current_stam: float) # Current stamina value
signal win_game() # When 
signal lose_game()


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
	elif event is InputEventMouseMotion and is_dragging and not dead:
		rotate_y(-event.relative.x * mouse_sensitivity)
	if event is InputEventMouseMotion and is_dragging and dead:
		$CameraController.rotation.y -= event.relative.x * mouse_sensitivity
	if event.is_action_released("MB2"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
	#print(event.as_text())

# Loadup Settings - What to do when the scene loads. 
func _ready() -> void:
	startPosition = global_transform #This does not reset player rotation


# Physics Hub
func _physics_process(delta: float) -> void:
	
	# Add the gravity.
	if not is_on_floor():
		velocity += 2.5*get_gravity() * delta
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	dir = direction
	
	# Sprint conditions
	var is_moving = input_dir.length() > 0
	var is_sprinting = Input.is_action_pressed("sprint") and canSprint and is_moving
	
	# Handle Sprint and stamina
	if is_sprinting:
		sprintMod = sprintSpeed
		stamina -= stamEffic * delta
		stamina_changes.emit(stamina)
		if stamina <= 0:
			stamina = - 10.0
			canSprint = false
	else: 
		sprintMod = 0
		stamina += stamRegen * delta
		stamina_changes.emit(stamina)
		if stamina >= maxStamina:
			stamina = maxStamina
		if stamina >= 5:
			canSprint = true
	
	# Handle movement, else deceleration
	if direction:
		velocity.x = direction.x * (speed + sprintMod)
		velocity.z = direction.z * (speed + sprintMod)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	### DEBUGGER OUTPUT
	#print("Holding shift: ",Input.is_action_pressed("sprint"))
	#print("Moving WITH Stamina: ",bool(input_dir != Vector2.ZERO and stamina > 0))
	#print("Stamina: ",roundf(stamina),", sprint speed: ",sprintMod)
	

			
	
	move_and_slide()
	
	#Make CameraController match the position of the character
	#the dollar sign lets you access a node within the root node by name
	# reference the position of the CameraController and set it equal to the
	# position of this node (Main Character), which needs no call 
	# MainCharacter.position == position. 
	# lerp(from,to,how fast) - Using delta should be considered as it would make 
	# the follow speed the same on all machines. Consider clamp in 3rd arg. 
	$CameraController.position = lerp($CameraController.position,position,clamp(60*0.35*delta,0.15,1))
	#Make CameraController match the rotation of the character
	$CameraController.rotation.y = rotation.y
	



# MainCharacter functions
##Adds 1 coin to Master.playerCoins
func add_coin():
	Master.playerCoins += 1
	coins_changed.emit(Master.playerCoins)
	if Master.playerCoins >= winCoins:
		end_game_win()
	
func kill_enemy():
	var kill_bounce = create_tween()
	kill_bounce.tween_property(self,"position",Vector3(0,0.4,0),0.1).as_relative()

func killed_by_enemy():
	set_physics_process(false)
	for mask in masks:
		set_collision_mask_value(collision_masks[mask],false)
	var hurt_tween = create_tween()
	health -= 1
	print(health)
	if health <= 0:
		hurt_tween.tween_property(self,"rotation_degrees",Vector3(90,0,0),1.3).set_trans(Tween.TRANS_ELASTIC)\
		.set_ease(Tween.EASE_IN)
		end_game_death()
	else:
		hurt_tween.tween_property(self,"position",-dir,0.2).set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_OUT).as_relative()
		await get_tree().create_timer(0.2).timeout
		set_physics_process(true)
		for mask in masks:
			set_collision_mask_value(collision_masks[mask],true)


##Resets Character to starting position with 0 speed.
func reset_position():
	global_transform = startPosition # this does not reset player rotation
	velocity = Vector3.ZERO 


## Run the end game script when the player meets the win criteria. 
func end_game_win():
	win_game.emit()
	# disallows any position changes, allows rotation. Locks the character from doing anything else.
	# Turns off _physics_process(). Since rotation is handled in _input(), you can still rotate.
	set_physics_process(false)
	# await pauses the function for a 5 second timer, restarts on .timeout
	await get_tree().create_timer(5).timeout
	#sets the scene to new scene alpha - restarting the level. # in the future, this should be
	# a menu screen, or next level. Preferrably menu. 
	get_tree().change_scene_to_file("res://alpha.tscn")
	
func end_game_death():
	for mask in masks:
		set_collision_mask_value(collision_masks[mask],false)
	health = 0
	lose_game.emit()
	dead = true


##Safety net to prevent infinite falling through world. 
func _on_death_barrier_body_entered(_body : Node3D) -> void:
	if _body == self:
		reset_position() # player rotation is not reset
