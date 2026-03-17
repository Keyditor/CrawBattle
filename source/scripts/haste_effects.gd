extends ItemEffects
class_name HasteEffects
enum upgradeType {Add,Multi}
enum hasteType {Self,Left,Right,All}

@export var haste:int
var newHaste:int = haste
var bonushaste:int
@export var tier_upgade:int
@export var upgrade_type:upgradeType
@export_range(1,100,1) var crit:int
@export var type_haste: hasteType
var color:Color = Color.PALE_TURQUOISE
var lsColor:Color = Color.GREEN

var rng =  RandomNumberGenerator.new()

func apply(_user, _item, _target):
	match upgrade_type:
		0:
			newHaste = haste + (tier_upgade*_item.tier)
		1:
			newHaste = haste * _item.tier
	print("Type Haste:",type_haste)
	match type_haste:
		0:     # haste self
			print("haste self")
			await _item.spawn_particle(
			_item.global_position,
			_item.global_position,
			color)
			_item.t += 1
		1:     # haste to the left
			print("haste left")
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
								await _item.get_tree().create_timer(0.55).timeout
								c.haste += newHaste
				else:
					print("haste player item")
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
								await _item.get_tree().create_timer(0.55).timeout
								c.haste += newHaste
								
		2:     # haste to the right
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
								await _item.get_tree().create_timer(0.55).timeout
								c.haste += newHaste
				else:
					for s in _item.slots_reservados:
						for r in c.slots_reservados:
							if r.ID == (s.ID + 1) and r.ocupado_por != _item and not r.ocupado_por.enemieItem:
								await _item.spawn_particle(
								_item.global_position,
								c.global_position,
								color
								)
								await _item.get_tree().create_timer(0.55).timeout
								c.haste += newHaste
		3:     # haste all
			for c in _item.get_tree().get_nodes_in_group("items"):
				if _item.enemieItem == true:
					if c.enemieItem:
						await _item.spawn_particle(
								_item.global_position,
								c.global_position,
								color
								)
						await _item.get_tree().create_timer(0.55).timeout
						c.haste += newHaste
				else:
					if not c.enemieItem:
						await _item.spawn_particle(
								_item.global_position,
								c.global_position,
								color
								)
						await _item.get_tree().create_timer(0.55).timeout
						c.haste += newHaste

func updateValue(_item):
	pass
