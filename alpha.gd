extends Node3D

@export var coins_to_win := 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Master.playerCoins = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
