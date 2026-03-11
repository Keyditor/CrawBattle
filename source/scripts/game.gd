extends Node

@onready var timer := Timer.new()
signal itemUpgrade(item,caller)
var EnemieMaxHp : int = 0
var EnemieHp : int = 450
var EnemieShield : int = 0
var EnemieBurn : int = 0
var EnemiePoison : int = 0
var itemSemSlot = false
var checkUpgrade = false
var tickEnable = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func queueUpgrade():
	await get_tree().create_timer(0.3).timeout
	checkUpgrade=true
	await get_tree().create_timer(0.3).timeout
	checkUpgrade=false
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
