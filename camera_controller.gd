extends Node3D

#For Character rotation
var is_dragging: bool = false
@export var mouse_sensitivity: float = 0.007

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

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
