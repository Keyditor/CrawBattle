extends Node3D
class_name Inventory
var slots := []
var itens := []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	slots = get_children().filter(func(c): return c is Area3D)
	slots.sort_custom(func(a,b): return a.ID < b.ID)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
