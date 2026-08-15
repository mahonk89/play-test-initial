extends Camera3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

const RAY_LENGTH = 1000.0

func _physics_process(_delta: float) -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_origin = project_ray_origin(mouse_pos)
	var ray_end = ray_origin + project_ray_normal(mouse_pos) * RAY_LENGTH
	
	# Access the 3D physics world state
	var space_state = get_world_3d().direct_space_state
	
	# Configure the ray query
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	# Optional: query.exclude = [self] # Exclude objects if needed
	
	var result = space_state.intersect_ray(query)
	
	if not result.is_empty():
		var hit_position: Vector3 = result.position
		print("3D Mouse Position on Object: ", hit_position)
		# You can also get the object hit via: result.collider
