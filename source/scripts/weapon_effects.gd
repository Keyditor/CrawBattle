extends ItemEffects
class_name WeaponEffects
enum upgradeType {Add,Multi}

@export var damage:int
var newDamage:int = damage
var bonusDamage:int
@export var tier_upgade:int
@export var upgrade_type:upgradeType
@export_range(1,100,1) var crit:int
@export var life_steal: bool
var color:Color = Color.RED
var lsColor:Color = Color.GREEN

var rng =  RandomNumberGenerator.new()

func apply(_user, _item, _target):
	var vec = Vector3(randf_range(0,0.8), 0, randf_range(0,-0.8))
	await _item.spawn_particle(
			_item.global_position,
			_target.global_position+vec,
			color
		)
	await _item.get_tree().create_timer(0.55).timeout
	var dmg = preload("res://scenes/DamageIndicator.tscn").instantiate()
	var lst = preload("res://scenes/DamageIndicator.tscn").instantiate()
	_target.get_tree().current_scene.add_child(dmg)
	dmg.global_position = _target.global_position + Vector3.UP * 2
	var toCrit = false
	var critRoll = rng.randi_range(1,100)
	print(critRoll)
	if critRoll <= crit:
		toCrit = true
	else: toCrit = false
	match upgrade_type: 
		0:
			if _item.tier > 0:
				newDamage = (damage+tier_upgade*_item.tier)+bonusDamage
				print("nb: ",newDamage)
			else:
				newDamage = damage+bonusDamage
				print("nb: ",newDamage)
		1:
			if _item.tier > 0:
				newDamage = (damage*(_item.tier+1))+bonusDamage
			else:
				newDamage = damage+bonusDamage
	if critRoll <= crit:
		_target.damage(newDamage*2, toCrit)
		dmg.setup(newDamage*2, Vector3.RIGHT, color, toCrit, _target)
	else:
		_target.damage(newDamage)
		dmg.setup(newDamage, Vector3.RIGHT, color, toCrit, _target)
	if life_steal:
		if critRoll <= crit:
			_user.heal(newDamage*2,toCrit)
			_user.get_tree().current_scene.add_child(lst)
			lst.setup(newDamage*2, Vector3.LEFT, lsColor, toCrit, _user.userPos)
		else:
			_user.heal(newDamage)
			_user.get_tree().current_scene.add_child(lst)
			lst.setup(newDamage, Vector3.LEFT, lsColor, toCrit, _user.userPos)

func updateValue (_item):
	match upgrade_type: 
		0:
			if _item.tier > 0:
				newDamage = (damage+tier_upgade*_item.tier)+bonusDamage
				print("nb: ",newDamage)
			else:
				newDamage = damage+bonusDamage
				print("nb: ",newDamage)
		1:
			if _item.tier > 0:
				newDamage = (damage*(_item.tier+1))+bonusDamage
			else:
				newDamage = damage+bonusDamage
