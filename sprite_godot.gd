extends Sprite3D

var n = 0

# keep track of time elapsed in _process() begining at t=0
var time_elapsed: float = 0.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotate_y(0.5*delta) # continuous rotation along the y axis
	time_elapsed += delta # time tracker
	var pulse = 5.5 + (sin(time_elapsed * 2) * 1.5) #pulsing scale based on time & sine wave
	set_scale(Vector3(pulse, pulse, pulse)) # set the scale continuously using pulse
