extends Node3D
@export var health : int = 0
var shield : int = 250
var burn : int = 0
var poison : int = 0
var type = "enemy"

@onready var uiVida = $SubViewport/HBoxContainer/Vida
@onready var uiShield = $SubViewport/HBoxContainer/Shield
@onready var uiBurn = $SubViewport/HBoxContainer/Burn
@onready var uiPoison = $SubViewport/HBoxContainer/Poison
@onready var userPos = self


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Game.stopBattle.connect()  # Preparado para meconicade win e lose
	GlobalTick.half_tick.connect(_on_half_tick)
	GlobalTick.tick.connect(_on_tick)
	await get_tree().process_frame
	add_to_group("enemie")
	Game.EnemieHp = health
	Game.EnemieMaxHp = health
	Game.EnemieBurn = burn
	Game.EnemieShield = shield
	Game.EnemiePoison = poison
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
	else:
		if shield > 0:
			shield -= n
			return
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

func addPoison(n,c=false):
	if c:
		poison += n
	else:
		poison += n

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	Game.EnemieHp = health
	Game.EnemieBurn = burn
	Game.EnemieShield = shield
	Game.EnemiePoison = poison
	$SubViewport/HealthBar.value = health
	$SubViewport/HealthBar.max_value = Game.EnemieMaxHp
	$SubViewport/ShieldBar.value = shield
	$SubViewport/ShieldBar.max_value = Game.EnemieMaxHp
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
			Game.stopBattle.emit("enemie")
	
	pass
