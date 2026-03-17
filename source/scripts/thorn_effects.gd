extends ItemEffects
class_name ThornEffects
enum upgradeType {Add,Multi}

@export_range(1,100,1) var percentage:float = 1
var newPercentage : float = percentage
var damage : int = 0
var newDamage:int = damage
var bonusDamage:int
@export var tier_upgade:int
@export var upgrade_type:upgradeType
@export_range(1,100,1) var crit:int
@export var life_steal: bool
var color:Color = Color.DARK_SLATE_GRAY
var lsColor:Color = Color.GREEN

var rng =  RandomNumberGenerator.new()

func apply(_user, _item, _target):
	var targetPos = _target.userPos
	var vec:Vector3
	if _user.type == "hero":
		vec = Vector3(randf_range(0,0.8), 0, randf_range(0,-0.8))
	else:
		vec = Vector3(randf_range(0,-0.8), 0, randf_range(0,0.8))
	
	await _item.spawn_particle(
			_item.global_position,
			targetPos.global_position+vec,
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
				newDamage = damage*((percentage+tier_upgade)/100)
				print("nb: ",newDamage)
			else:
				newDamage = damage*(percentage/100)
				print("nb: ",newDamage)
		1:
			if _item.tier > 0:
				newDamage = damage*((percentage*(tier_upgade+1))/100)
			else:
				newDamage = damage*(percentage/100)
	if critRoll <= crit:
		_target.damage(newDamage*2, toCrit)
		dmg.setup(newDamage*2, Vector3.RIGHT, color, toCrit, targetPos)
	else:
		_target.damage(newDamage)
		dmg.setup(newDamage, Vector3.RIGHT, color, toCrit, targetPos)
	if life_steal:
		if critRoll <= crit:
			_user.heal(newDamage*2,toCrit)
			_user.get_tree().current_scene.add_child(lst)
			lst.setup(newDamage*2, Vector3.LEFT, lsColor, toCrit, _user.userPos)
		else:
			_user.heal(newDamage)
			_user.get_tree().current_scene.add_child(lst)
			lst.setup(newDamage, Vector3.LEFT, lsColor, toCrit, _user.userPos)

func updateValue (_item, n):
	damage = n
	match upgrade_type: 
		upgradeType.Add:
			if _item.tier > 0:
				newPercentage = percentage+tier_upgade
				newDamage = damage*((percentage+tier_upgade)/100)
				print("nb: ",newDamage)
			else:
				newPercentage = percentage
				newDamage = damage*(percentage/100)
				print("nb: ",newDamage)
		upgradeType.Multi:
			if _item.tier > 0:
				newPercentage = percentage*(tier_upgade+1)
				newDamage = damage*((percentage*(tier_upgade+1))/100)
			else:
				newPercentage = percentage
				newDamage = damage*(percentage/100)
