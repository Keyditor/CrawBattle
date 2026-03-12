extends ItemEffects
class_name PoisonEffects
enum upgradeType {Add,Multi}

@export var poison:int
var newPoison : int = poison
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
	match upgradeType: #corrigir problema de match com enum
		0:
			if _item.tier > 0:
				newPoison = poison+tier_upgade*_item.tier
			else:
				newPoison = poison
		1:
			if _item.tier > 0:
				newPoison = poison*(_item.tier+1)
			else:
				newPoison = poison
	if critRoll <= crit:
		_target.addPoison((poison*(_item.tier+1))*2, toCrit)
		dmg.setup((poison*(_item.tier+1))*2, Vector3.LEFT, Color.REBECCA_PURPLE, toCrit, _target)
	else:
		_target.addPoison(poison*(_item.tier+1))
		dmg.setup(poison*(_item.tier+1), Vector3.LEFT, Color.REBECCA_PURPLE, toCrit, _target)
