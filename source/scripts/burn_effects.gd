extends ItemEffects
class_name BurnEffects
enum upgradeType {Add,Multi}

@export var burn:int
var newBurn : int = burn
var bonusBurn : int
@export var tier_upgade:int
@export var upgrade_type:upgradeType
@export_range(1,100,1) var crit:int
#@export var life_steal: bool
var color:Color = Color.DARK_ORANGE

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
	match upgrade_type: 
		0:
			if _item.tier > 0:
				newBurn = (burn+tier_upgade*_item.tier)+bonusBurn
				#print("nb: ",newBurn)
			else:
				newBurn = burn+bonusBurn
				#print("nb: ",newBurn)
		1:
			if _item.tier > 0:
				newBurn = (burn*(_item.tier+1))+bonusBurn
			else:
				newBurn = burn+bonusBurn
	if critRoll <= crit:
		_target.addBurn(newBurn*2, toCrit)
		dmg.setup((newBurn)*2, Vector3.LEFT, color, toCrit, targetPos)
	else:
		_target.addBurn(newBurn)
		dmg.setup(newBurn, Vector3.LEFT, color, toCrit, targetPos)
func updateValue (_item):
	match upgrade_type: 
		0:
			if _item.tier > 0:
				newBurn = (burn+tier_upgade*_item.tier)+bonusBurn
				#print("nb: ",newBurn)
			else:
				newBurn = burn+bonusBurn
				#print("nb: ",newBurn)
		1:
			if _item.tier > 0:
				newBurn = (burn*(_item.tier+1))+bonusBurn
			else:
				newBurn = burn+bonusBurn
