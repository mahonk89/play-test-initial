extends Node3D
# Please keep in mind the x,y,z definitions. To MOVE along the x-axis, you are going LEFT and RIGHT; 
# so take that left/right line and rotate around that. To ROTATE along the x-axis, you are rotating
# vertically (up/down) around that axis (like a gymnast). To MOVE along the y-axis is to go UP and DOWN;
# to ROTATE along the y-axis, you are rotating horizontally around that axis (like a tetherball). 

@export var y_cameraSensativity := 0.005 # y horizontal
@export var x_cameraSensativity := 0.005 # x vertical
#@export var joy_y_acceleration := 1.0 # y horizontal - #d out because it's not implemented yet. 
#@export var joy_x_acceleration := 2.0 # x vertical - #d out because it's not implemented yet. 


# Handles camera rotation in the y direction (left/right)
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_from_vector(event.relative)
		#rotation.y -= event.relative.x * y_cameraSensativity

# small function to handle both keyboard input and controller input.
func rotate_from_vector(v: Vector2):
	if v.length() != 0: 
		rotation.y -= v.x * y_cameraSensativity
		rotation.x += v.y * x_cameraSensativity
		#Does not allow x rotation to go above or below certain limits. 
		rotation.x = clamp(rotation.x,deg_to_rad(-69),deg_to_rad(20))
	
# Handles controller rotation in y direction (left/right). Everything is commented out because
# the input maps DO NOT EXIST yet. 
#func _process(delta: float) -> void:
	# Input Maps have not yet been defined. This should be the RIGHT joystick. 
	#var joy_dir = Input.get_vector("pan_left","pan_right","pan_up","pan_down")
	#rotate_from_vector(joy_dir*delta*Vector2(joy_x_acceleration,joy_y_acceleration))

# COMMENTS

#func rotate_from_vector() specifing return makes the function output the work it did, instead of just doing it. 
#in this case, 
#	if v.length() == 0: return --- means if velocity is 0, do nothing, return nothing.
#	rotation.y -= v.x --- otherwise (if not 0), run rotation.y -= v.x
#I just changed this to 
#	if v.length() != 0: 
#		rotation.y -=v.x 
#because I would rather the if condition be true to get my result instead of purely relying on the false outcome. 

# FUTURE GOALS

# Mouse wheel scroll in/out zooms in and out. Preferably transform y and z.. Vector?
# Character movement based on camera direction. Possibly with modifier
	# i.e. in wow, left click moves camera, not player. Right click moves both. 
	
