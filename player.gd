extends CharacterBody3D

# the colon modifier prior to the equal sign implies a locked variable
# but lets GDScript assume what you're locking it to. i.e., 
# var base_speed : float = 4.0 == var base_speed := 4.0 are the same
# @export will send the created variable to the Inspector pane. 
@export var base_speed := 4.0

var movement_input := Vector2.ZERO

func _physics_process(_delta: float) -> void:
	movement_input = Input.get_vector("left","right","forward","backward")
	velocity = Vector3(movement_input.x,0,movement_input.y)*base_speed
	move_and_slide()
