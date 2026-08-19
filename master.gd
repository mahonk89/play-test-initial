extends Node

var playerCoins := 0


#@onready var player1_stamina = $MainCharacter.get_stamina()

func _ready() -> void:
	pass
	#print(player1_stamina)
	

func get_character():
	var playernode1 = get_tree().get_first_node_in_group("Players")
	print(playernode1)
