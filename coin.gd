extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotate_y(PI/3*delta)


func _on_body_entered(body: Node3D) -> void:
	#checks the established functions of the body that enters this area
	#players should have the add_coin() func, others won't. If a non-player
	#collision body enters, the coin will not be collected nor disappear. 
	if body.has_method("add_coin"):
		#calls the method(node specific function) for the player entering
		$Bounce.play("bounce")
		set_collision_layer_value(1,false)
		body.add_coin()
		#removes the coin from the level
		
	


func _on_bounce_animation_finished(_anim_name: StringName) -> void:
	queue_free()
