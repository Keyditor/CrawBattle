extends ItemEffects
class_name WeaponEffects

@export var damage:int
@export_range(1,100,1) var crit:int
@export var life_steal: bool

var rng =  RandomNumberGenerator.new()

func apply(_user, _item, _target):
	var toCrit = false
	var critRoll = rng.randi_range(1,100)
	if critRoll <= crit:
		toCrit = true
	else: toCrit = false
	
	if critRoll <= crit:
		_target.damage(damage*2, toCrit)
	else:
		_target.damage(damage)
	if life_steal:
		if critRoll <= crit:
			_user.heal(damage*2,toCrit)
		else:
			_user.heal(damage)
