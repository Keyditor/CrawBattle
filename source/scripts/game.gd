extends Node

@onready var timer := Timer.new()

var itemSemSlot = false
var checkUpgrade = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func queueUpgrade():
	await get_tree().create_timer(0.1).timeout
	checkUpgrade=true
	await get_tree().create_timer(0.1).timeout
	checkUpgrade=false
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
