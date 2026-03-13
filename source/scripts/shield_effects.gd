extends ItemEffects
class_name ShieldEffects
enum upgradeType {Add,Multi}

@export var shield:int
var newShield : int = shield
var bonusShield : int
@export var tier_upgade:int
@export var upgrade_type:upgradeType
@export_range(1,100,1) var crit:int
#@export var life_steal: bool

var rng =  RandomNumberGenerator.new()

func apply(_user, _item, _target):
	var dmg = preload("res://scenes/DamageIndicator.tscn").instantiate()
	#var lst = preload("res://scenes/DamageIndicator.tscn").instantiate()
	_target.get_tree().current_scene.add_child(dmg)
	dmg.global_position = _target.global_position + Vector3.UP * 2
	var toCrit = false
	var critRoll = rng.randi_range(1,100)
	print(critRoll)
	if critRoll <= crit:
		toCrit = true
	else: toCrit = false
	match upgrade_type: #corrigir problema de match com enum
		0:
			if _item.tier > 0:
				newShield = (shield+tier_upgade*_item.tier)+bonusShield
			else:
				newShield = shield+bonusShield
		1:
			if _item.tier > 0:
				newShield = (shield*(_item.tier+1))+bonusShield
			else:
				newShield = shield+bonusShield
	if critRoll <= crit:
		_user.addShield((shield*(_item.tier+1))*2, toCrit)
		dmg.setup((shield*(_item.tier+1))*2, Vector3.LEFT, Color.BLUE, toCrit, _user)
	else:
		_user.addShield(shield*(_item.tier+1))
		dmg.setup(shield*(_item.tier+1), Vector3.LEFT, Color.BLUE, toCrit, _user)

func updateValue (_item):
	match upgrade_type: #corrigir problema de match com enum
		0:
			if _item.tier > 0:
				newShield = shield+tier_upgade*_item.tier
				print("nb: ",newShield)
			else:
				newShield = shield
				print("nb: ",newShield)
		1:
			if _item.tier > 0:
				newShield = shield*(_item.tier+1)
			else:
				newShield = shield
