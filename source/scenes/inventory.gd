extends Node3D

var items : Array = []
var slots : Array = []
var slotsPos : Dictionary = {}

func add_item(new_item):

	# Procurar item com mesmo ID
	for item in items:
		if item.name == new_item.name:
			upgrade_item(item)
			new_item.queue_free()
			return
	
	# Se não existir, adiciona normalmente
	items.append(new_item)
	add_child(new_item)
	add_item_on(new_item)

func upgrade_item(item):
	
	if item.tier < 4:
		item.tier += 1
		item.colorNshade()
	else:
		print("Item já está no tier máximo")


func add_item_on(item):
	
	var indice = encontrar_espaco(item.slots_necessarios)
	
	if indice == -1:
		print("Sem espaço disponível")
		return false
	
	# Reservar slots
	for i in range(item.slots_necessarios):
		slots[indice + i] = item
	
	posicionar_item_visual(item, indice)
	
	return true

func posicionar_item_visual(item, indice):
	for m in slotsPos:
		if m == indice:
			match item.slots_necessarios:
				1:
					var pos = slotsPos[m]
					global_position = Vector3(pos.x, global_position.y, pos.z)
				2:
					var pos1 = slotsPos[m]
					var pos2 = slotsPos[m+1]
					var meio = (pos1 + pos2) / 2.0
					global_position = Vector3(meio.x, global_position.y, meio.z)
				3:
					# Slot do meio
					var meio_slot = slotsPos[m+1]
					var pos = meio_slot.global_position
					global_position = Vector3(pos.x, global_position.y, pos.z)
			return
	pass

func liberar_slots(item):

	for i in 9:
		if slots[i] == item:
			slots[i] = null

func encontrar_espaco(tamanho : int) -> int:
	
	for i in range(9 - tamanho + 1):
		
		var livre := true
		
		for j in range(tamanho):
			if slots[i + j] != null:
				livre = false
				break
		
		if livre:
			return i
	
	return -1

func _ready():
	slots.resize(9)
	for i in 9:
		slots[i] = null
	var indice = 0
	for j in get_children():
		slotsPos[indice] = Vector3(j.global_position)
		print(indice,"  ",slotsPos[indice])
		indice += 1
	
