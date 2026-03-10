extends Node3D
@export var health : float
var shield : float
var burn : int
var poison : int
@export var wins : int
@export var loses : int
@onready var cam = $Camera3D
@onready var anim = $AnimationPlayer
var battle = false
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

func damage(n,c=false):
	if c:
		health -= n
	else:
		health -= n

func heal(n,c=false):
	if c:
		health += n
	else:
		health += n

func addShield(n,c=false):
	if c:
		shield += n
	else:
		shield += n

func addBurn(n,c=false):
	if c:
		burn += n
	else:
		burn += n

func AddPoison(n,c=false):
	if c:
		poison += n
	else:
		poison += n

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
		instancia.slots_necessarios = 3
		instancia.itemImage = preload("res://voxels/largePlaceholder.jpg")
		instancia.tier = 0
		add_child(instancia)
	pass
