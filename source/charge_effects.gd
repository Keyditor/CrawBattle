extends ItemEffects
class_name ChargeEffects
enum upgradeType {Add,Multi}
enum chargeType {Self,Left,Right,All}

@export var charge:int
var newCharge:int = charge
var bonusCharge:int
@export var tier_upgade:int
@export var upgrade_type:upgradeType
@export_range(1,100,1) var crit:int
@export var type_charge: chargeType
var color:Color = Color.WHITE
var lsColor:Color = Color.GREEN

var rng =  RandomNumberGenerator.new()

func apply(_user, _item, _target):
	match upgrade_type:
		0:
			newCharge = charge + (tier_upgade*_item.tier)
		1:
			newCharge = charge * _item.tier
	print("Type Charge:",type_charge)
	match type_charge:
		0:     # charge self
			print("charge self")
			await _item.spawn_particle(
			_item.global_position,
			_item.global_position,
			color)
			_item.t += 1
		1:     # charge to the left
			print("charge left")
			for c in _item.get_tree().get_nodes_in_group("items"):
				if _item.enemieItem == true:
					for s in _item.slots_reservados:
						for r in c.slots_reservados:
							if r.ID == (s.ID - 1) and r.ocupado_por != _item and r.ocupado_por.enemieItem:
								await _item.spawn_particle(
								_item.global_position,
								c.global_position,
								color
								)
								c.t += newCharge
				else:
					print("charge player item")
					for s in _item.slots_reservados:
						print("tensting with item slot ", s.ID)
						for r in c.slots_reservados:
							print("tensting with target slot ", s.ID)
							if r.ID == (s.ID - 1) and r.ocupado_por != _item and not r.ocupado_por.enemieItem:
								print("charging item:", c.itemName)
								await _item.spawn_particle(
								_item.global_position,
								c.global_position,
								color
								)
								c.t += newCharge
								
		2:     # charge to the right
			for c in _item.get_tree().get_nodes_in_group("items"):
				if _item.enemieItem == true:
					for s in _item.slots_reservados:
						for r in c.slots_reservados:
							if r.ID == (s.ID + 1) and r.ocupado_por != _item and r.ocupado_por.enemieItem:
								await _item.spawn_particle(
								_item.global_position,
								c.global_position,
								color
								)
								c.t += newCharge
				else:
					for s in _item.slots_reservados:
						for r in c.slots_reservados:
							if r.ID == (s.ID + 1) and r.ocupado_por != _item and not r.ocupado_por.enemieItem:
								await _item.spawn_particle(
								_item.global_position,
								c.global_position,
								color
								)
								c.t += newCharge
		3:     # charge all
			for c in _item.get_tree().get_nodes_in_group("items"):
				if _item.enemieItem == true:
					if c.enemieItem:
						await _item.spawn_particle(
								_item.global_position,
								c.global_position,
								color
								)
						c.t += newCharge
				else:
					if not c.enemieItem:
						await _item.spawn_particle(
								_item.global_position,
								c.global_position,
								color
								)
						c.t += newCharge

func updateValue(_item):
	pass
