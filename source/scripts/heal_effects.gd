extends ItemEffects
class_name HealEffects
enum upgradeType {Add,Multi}

@export var heal:int
var newHeal : int = heal
var bonusHeal : int
@export var tier_upgade:int
@export var upgrade_type:upgradeType
@export_range(1,100,1) var crit:int
#@export var life_steal: bool
var color:Color = Color.GREEN

var rng =  RandomNumberGenerator.new()

func apply(_user, _item, _target):
	var vec = Vector3(randf_range(0,-0.8), 0, randf_range(0,0.8))
	await _item.spawn_particle(
			_item.global_position,
			_user.userPos.global_position+vec,
			color
		)
	await _item.get_tree().create_timer(0.55).timeout
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
				newHeal = (heal+tier_upgade*_item.tier)+bonusHeal
			else:
				newHeal = heal+bonusHeal
		1:
			if _item.tier > 0:
				newHeal = (heal*(_item.tier+1))+bonusHeal
			else:
				newHeal = heal+bonusHeal
	if critRoll <= crit:
		_user.heal((heal*(_item.tier+1))*2, toCrit)
		dmg.setup((heal*(_item.tier+1))*2, Vector3.LEFT, color, toCrit, _user.userPos)
	else:
		_user.heal(heal*(_item.tier+1))
		dmg.setup(heal*(_item.tier+1), Vector3.LEFT, color, toCrit, _user.userPos)

func updateValue (_item):
	match upgrade_type: #corrigir problema de match com enum
		0:
			if _item.tier > 0:
				newHeal = heal+tier_upgade*_item.tier
				#print("nb: ",newHeal)
			else:
				newHeal = heal
				#print("nb: ",newHeal)
		1:
			if _item.tier > 0:
				newHeal = heal*(_item.tier+1)
			else:
				newHeal = heal
