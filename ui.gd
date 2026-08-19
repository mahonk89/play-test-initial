extends Control

@onready var coin_label : Label = $CoinLabel
@onready var stamina_label : Label = $Stamina
var player_1 : Node3D # declaring a blank variable as Node3D for _ready() function


#func update_coin_amount(amount : int) -> void:
	#coin_label.text = "Coins: " + str(amount)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#get_tree() returns the scene tree that contains this node. This node is a scene within alpha, 
	#so it will be calling alpha // get_nodes_in_group creates an array of all the nodes in the Global group
	#in this case "Players" which has 1 Node3D in the group. Use [n] to pull the n+1 node from that array
	# which will be the first player in that group aka MainCharacter. 
	# to declare a new Global Group, go to Project Settings > Globals > Groups
	#By doing this, I can now call properties and methods of player_1 (MainCharacter) in this script.
	player_1 = get_tree().get_nodes_in_group("Players")[0]
	
	stamina_label.text =  "Stamina: " + str(player_1.stamina) + "/" + str(player_1.maxStamina)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

#this new function was created when adding the new signal. Click the green arrow icon
#to the left of the func line to see 
#[Source=MainCharacter/ Signal=coins_changed / Target=UI]
#func _on_[Source]_[Signal](var)
#Remember this signal was defined in main_character.gd
	#in add_coin() this signal is called - it "emits" a signal
	#which must be received. This call code below is the receiver. In other words:
#When main_character's coins change, catch the signal it emits (which is updated coin count)
	#then update the coin label text on the UI to show the new coin amount
#func _on_main_character_coins_changed(new_amount: int) -> void:
	#coin_label.text = "Coins: " + str(new_amount)


func _on_main_character_coins_changed(new_amount: int) -> void:
	coin_label.text = "Coins: " + str(new_amount)


func _on_main_character_stamina_changes(current_stam: float) -> void:
	stamina_label.text = "Stamina: " + str(clampi(int(current_stam),0,player_1.maxStamina)) \
	+ "/" + str(player_1.maxStamina)  # current stam is float, we don't need non-integer value appearing on screen. 
