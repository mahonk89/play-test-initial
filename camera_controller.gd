extends Node3D

#For Character rotation
var is_dragging: bool = false
## X-axis mouse sensitivity (up/down direction). To adjust the y-axis (left/right movement),
## go to Main Character / Mouse Sensitivity. 
@export var mouse_sensitivity: float = 0.002

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	
	# Check if right mouse button is clicked/released
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			is_dragging = event.pressed
	# Rotate character when dragging the mouse
	elif event is InputEventMouseMotion and is_dragging:
		rotation.x -= event.relative.y * mouse_sensitivity
		rotation.x = clamp(rotation.x, deg_to_rad(-50),deg_to_rad(20))
	#InputEventMouseMotion.relative will produce a Vector2 relative to the position AT LAST FRAME
#So, in order to use this .relative we should ADD or SUBTRACT this vector amount to the rotation
# NOT set the rotation equal to, as it would always be resetting to near zero amounts when 
#mouse stops moving. 

	# Handle Camera Zoom
	if event is InputEventMouseButton:
		# Zoom out
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and $CameraTarget.position.z < 8:
			$CameraTarget.position.z += 0.2
		
		# Zoom in
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and $CameraTarget.position.z >= 0.2:
			$CameraTarget.position.z -= 0.2
