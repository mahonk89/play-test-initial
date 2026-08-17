extends Control

@onready var coin_label : Label = $CoinLabel


#func update_coin_amount(amount : int) -> void:
	#coin_label.text = "Coins: " + str(amount)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
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
func _on_main_character_coins_changed(new_amount: int) -> void:
	coin_label.text = "Coins: " + str(new_amount)
