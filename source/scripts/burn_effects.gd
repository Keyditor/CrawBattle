extends ItemEffects
class_name BurnEffects
enum upgradeType {Add,Multi}

@export var burn:int
var newBurn : int = burn
@export var tier_upgade:int
@export var upgrade_type:upgradeType
@export_range(1,100,1) var crit:int
#@export var life_steal: bool

var rng =  RandomNumberGenerator.new()

func apply(_user, _item, _target):
	#newBurn = burn
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
				newBurn = burn+tier_upgade*_item.tier
				print("nb: ",newBurn)
			else:
				newBurn = burn
				print("nb: ",newBurn)
		1:
			if _item.tier > 0:
				newBurn = burn*(_item.tier+1)
			else:
				newBurn = burn
	if critRoll <= crit:
		_target.addBurn(newBurn*2, toCrit)
		dmg.setup((newBurn)*2, Vector3.LEFT, Color.DARK_ORANGE, toCrit, _target)
	else:
		_target.addBurn(newBurn)
		dmg.setup(newBurn, Vector3.LEFT, Color.DARK_ORANGE, toCrit, _target)
func updateValue (_item):
	match upgrade_type: #corrigir problema de match com enum
		0:
			if _item.tier > 0:
				newBurn = burn+tier_upgade*_item.tier
				print("nb: ",newBurn)
			else:
				newBurn = burn
				print("nb: ",newBurn)
		1:
			if _item.tier > 0:
				newBurn = burn*(_item.tier+1)
			else:
				newBurn = burn
