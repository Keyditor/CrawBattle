extends Node3D
@export var health : float
@export var wins : int
@export var loses : int
@onready var cam = $Camera3D
@onready var anim = $AnimationPlayer
var camPos = "ground"
var bagSlots = 9
var groundSlots = 9
var bag = []
var ground = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bag.resize(bagSlots)
	bag.fill(null)
	ground.resize(groundSlots)
	ground.fill(null)
	
	
	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept") and not anim.is_playing():
		print("press: ui_accept")
		if camPos == "ground":
			anim.play("to_stash")
			await anim.animation_finished
			camPos = "stash"
		else:
			anim.play("to_ground")
			await anim.animation_finished
			camPos = "ground"
	if Input.is_action_just_pressed("ui_cancel"):
		var test = preload("res://scenes/itens/item_test_1.tscn")
		var instancia = test.instantiate()
		instancia.slots_necessarios = 1
		instancia.itemImage = preload("res://voxels/smallPlaceholder.jpg")
		instancia.tier = 2
		add_child(instancia)
	pass
