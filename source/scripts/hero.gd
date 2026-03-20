extends Node3D
@export var health : int
var maxHealth : int
var shield : int
var burn : int
var poison : int
var type = "hero"
@export var wins : int
@export var loses : int
@onready var cam = $Camera3D
@onready var anim = $AnimationPlayer
@onready var healthBar = $HeroHp/SubViewport/HealthBar
@onready var shieldBar = $HeroHp/SubViewport/ShieldBar
@onready var uiVida = $HeroHp/SubViewport/HBoxContainer/Vida
@onready var uiShield = $HeroHp/SubViewport/HBoxContainer/Shield
@onready var uiBurn = $HeroHp/SubViewport/HBoxContainer/Burn
@onready var uiPoison = $HeroHp/SubViewport/HBoxContainer/Poison
@onready var userPos = $HeroHp
var battle = false
var camPos = "ground"
var bagSlots = 9
var groundSlots = 9
var bag = []
var ground = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Game.stopBattle.connect()  # Preparado para meconicade win e lose
	GlobalTick.half_tick.connect(_on_half_tick)
	GlobalTick.tick.connect(_on_tick)
	maxHealth = 1000
	healthBar.max_value = maxHealth
	shieldBar.value = 0
	shieldBar.max_value = maxHealth
	Game.tickEnable = true
	bag.resize(bagSlots)
	bag.fill(null)
	ground.resize(groundSlots)
	ground.fill(null)
	add_to_group("hero")
	
	pass # Replace with function body.

func _on_half_tick():
	#print("Tentando queimar")
	if burn > 0:
		if shield > 0:
			shield -= burn
			burn -= 1
			#print("BURN!")
		else:
			health -= burn
			burn -= 1
			#print("BURN!")

func _on_tick():
	if poison > 0:
		health -= poison

func damage(n,c=false):
	if c:
		if shield > 0:
			shield -= n
			return
		health -= n
		Game.onDamage.emit("hero",n)
	else:
		if shield > 0:
			shield -= n
			return
		health -= n
		Game.onDamage.emit("hero",n)

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

func addPoison(n,c=false):
	if c:
		poison += n
	else:
		poison += n

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if health > maxHealth:
		health = maxHealth
	healthBar.max_value = maxHealth
	healthBar.value = health
	shieldBar.value = shield
	shieldBar.max_value = maxHealth
	uiVida.text = str(health)
	uiShield.text = str(shield)
	uiBurn.text = str(burn)
	uiPoison.text = str(poison)
	if shield <= 0: uiShield.visible = false
	else: uiShield.visible = true
	if burn <= 0: uiBurn.visible = false
	else: uiBurn.visible = true
	if poison <= 0: uiPoison.visible = false
	else: uiPoison.visible = true
	if shield <= 0:
			shield = 0
	if health <= 0:
			health = 0
			Game.stopBattle.emit("player")
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
		var test2 = preload("res://scenes/itens/item_test_2.tscn")
		var instancia = test.instantiate()
		var instancia2 = test2.instantiate()
		instancia.slots_necessarios = 2
		instancia.itemImage = preload("res://voxels/mediumPlaceholder.jpeg")
		instancia.tier = 2
		instancia.spawn = "board"
		instancia.base_cooldown = 15
		add_child(instancia)
		await get_tree().create_timer(0.2).timeout
		instancia2.slots_necessarios = 1
		instancia2.itemName = "teste2"
		instancia2.itemImage = preload("res://voxels/smallPlaceholder.jpg")
		instancia2.enemieItem=false
		instancia2.enemieSlotChoice = 5
		instancia2.tier = 4
		instancia2.base_cooldown = 3
		instancia2.spawn = "board"
		add_child(instancia2)
	pass
