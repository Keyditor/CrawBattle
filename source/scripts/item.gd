extends StaticBody3D
class_name Item
enum _Types {Melee, Ranged, Armor, Ring, Charm, Cape, Pet}

@export var itemName : String
@export_multiline("Descrição do item") var itemDescription : String
@export var itemImage : Texture2D
@export var camera: Camera3D
@export var float_height := 0.8
@export var base_y := 0.5
@export var return_speed := 6.0
@export var slots_necessarios: int = 1
@export var base_cooldown : int = 1
@export var types : Array[_Types]
@export var effects : Array[ItemEffects]
@export_range(0,4,1) var tier : int = 0
var cooldown_time := base_cooldown
var spawn = ""

@onready var mat2 = $Shape/Image2.material_override
@onready var damageUI = $SubViewport/VBoxContainer/HBoxContainer/Damage
@onready var shieldUI = $SubViewport/VBoxContainer/HBoxContainer/Shield
@onready var burnUI = $SubViewport/VBoxContainer/HBoxContainer/Burn
@onready var poisonUI = $SubViewport/VBoxContainer/HBoxContainer/Poison
@onready var healUI = $SubViewport/VBoxContainer/HBoxContainer2/Heal
@onready var cooldownUI = $Shape/Image2
@onready var mesh_instance: MeshInstance3D = $Shape
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var sprite: Sprite3D = $Shape/Image
@onready var label: Label3D = $Label3D

var adding = false
var oldItem = false
var slots_reservados: Array = []
var slots_encostando: Array = []
var slot_escolhido = null
var ultima_posicao_valida: Vector3
var drag_plane : Plane
var dragging := false
var is_floating := false
var target_y := base_y
var enemieItem = false
var enemieSlotChoice = 0
var hero
var target
var onBattle = false

func _input(event):
	if event is InputEventMouseButton and !enemieItem:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if is_mouse_over():
					start_drag()
					#print("sobe")
					
			else:
				stop_drag()
				#print("desce")

func _process(delta):
	if Input.is_action_just_pressed("C"):
		#await spawn_particle(
			#self.global_position,
			#Vector3(8.5,0,-5.6),
			#Color.DARK_ORANGE
		#)
		#await get_tree().create_timer(0.55).timeout
		#for node in get_tree().get_nodes_in_group("hero"):
			#hero = node
		#for node in get_tree().get_nodes_in_group("enemie"):
			#target = node
		#for e in effects:
			#e.apply(hero, self, target)
			#await get_tree().create_timer(0.1).timeout
		cooldownUI.visible = true
		onBattle = true
		Game.startBattle.emit()
	
	for e in effects:
		e.updateValue(self)
		if e is WeaponEffects:
			damageUI.text = str("[color=red]",e.newDamage,"[/color]")
		if e is ShieldEffects:
			shieldUI.text = str("[color=blue]",e.newShield,"[/color]")
		if e is BurnEffects:
			burnUI.text = str("[color=orange]",e.newBurn,"[/color]")
		if e is PoisonEffects:
			poisonUI.text = str("[color=purple]",e.newPoison,"[/color]")
		if e is HealEffects:
			healUI.text = str("[color=green]",e.newHeal,"[/color]")
	
	if Game.checkUpgrade and tier != 4:
		print(self.name,": dando upgrade consecutivo")
		var uItem = existe_item_igual()
		if uItem!=self: Game.itemUpgrade.emit(uItem, self); Game.checkUpgrade = false
		print("desligando upgrade")
	if !slots_reservados and !adding and !enemieItem:
		label.text = "Posicione o item em um slot vazio!"
	else:
		label.text = ""
	if dragging:
		move_to_mouse()
	# Suaviza subida e descida
		global_position.y = lerp(global_position.y, target_y, return_speed * delta)
	

func stop_cooldown(who):
	print(who)
	onBattle = false
	var t := 0.0
	var p = t / cooldown_time
	mat2.set_shader_parameter("progress", p)
	cooldownUI.visible = false

func start_cooldown():
	print("teste chehsque: ",slots_reservados[0].inventory.name)
	if slots_reservados[0].inventory.name == "onGorund":
		cooldown_time = base_cooldown
		var t := 0.0
		
		while t < cooldown_time:
			if onBattle:
				await get_tree().process_frame
				t += get_process_delta_time()
				
				var p = t / cooldown_time
				mat2.set_shader_parameter("progress", p)
			else:
				return
		for node in get_tree().get_nodes_in_group("hero"):
			hero = node
		for node in get_tree().get_nodes_in_group("enemie"):
			target = node
		start_cooldown()
		for e in effects:
			e.apply(hero, self, target)
			await get_tree().create_timer(0.1).timeout
	if slots_reservados[0].inventory.name == "enemieGorund":
		cooldown_time = base_cooldown
		var t := 0.0
		
		while t < cooldown_time:
			if onBattle:
				await get_tree().process_frame
				t += get_process_delta_time()
				
				var p = t / cooldown_time
				mat2.set_shader_parameter("progress", p)
			else:
				return
		for node in get_tree().get_nodes_in_group("hero"):
			hero = node
		for node in get_tree().get_nodes_in_group("enemie"):
			target = node
		start_cooldown()
		for e in effects:
			e.apply(target, self, hero)
			await get_tree().create_timer(0.1).timeout


func start_drag():
	dragging = true
	target_y = float_height
	drag_plane = Plane(Vector3.UP, float_height)
	#print(global_position.y)

func stop_drag():
	oldItem = true
	dragging = false
	global_position.y = base_y
	#print(global_position.y)
	atualizar_snap()

func move_to_mouse():
	var mouse_pos = get_viewport().get_mouse_position()
	
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_dir = camera.project_ray_normal(mouse_pos)
	
	var hit = drag_plane.intersects_ray(ray_origin, ray_dir)
	
	if hit:
		global_position.x = hit.x
		global_position.z = hit.z

func registrar_slot(slot):
	print("teste 123")
	if slot not in slots_encostando:
		slots_encostando.append(slot)
		#atualizar_snap()

func remover_slot(slot):
	slots_encostando.erase(slot)
	#atualizar_snap()

func atualizar_snap():
	print("COISO ",str(slots_encostando.size()))
	if slots_encostando.size() < slots_necessarios:
			voltar_para_ultima_posicao()
			return
	
	# Ordena pelo ID
	slots_encostando.sort_custom(func(a, b): return a.ID < b.ID)
	
	# Pega apenas a quantidade necessária
	var candidatos = slots_encostando.slice(0, slots_necessarios)
	
	# Verifica se todos são do mesmo inventário
	var inventario_base = candidatos[0].inventory
	
	for slot in candidatos:
		if slot.inventory != inventario_base:
			voltar_para_ultima_posicao()
			return
	# Verifica se slots estão livres
	for slot in candidatos:
		if not slot.esta_livre() and slot.ocupado_por != self:
			voltar_para_ultima_posicao()
			return
	# Verifica IDs consecutivos
	for i in range(candidatos.size() - 1):
		if candidatos[i+1].ID != candidatos[i].ID + 1:
			voltar_para_ultima_posicao()
			return
	
	# --- SNAP ---
	match slots_necessarios:
		
		1:
			var pos = candidatos[0].global_position
			global_position = Vector3(pos.x, global_position.y, pos.z)
		
		2:
			var pos1 = candidatos[0].global_position
			var pos2 = candidatos[1].global_position
			var meio = (pos1 + pos2) / 2.0
			global_position = Vector3(meio.x, global_position.y, meio.z)
		
		3:
			# Slot do meio
			var meio_slot = candidatos[1]
			var pos = meio_slot.global_position
			global_position = Vector3(pos.x, global_position.y, pos.z)
	liberar_slots_anteriores()
	for slot in candidatos:
		slot.reservar(self)
		slots_reservados.append(slot)
	ultima_posicao_valida = global_position

func voltar_para_ultima_posicao():
	global_position = ultima_posicao_valida

func is_mouse_over() -> bool:
	var mouse_pos = get_viewport().get_mouse_position()
	
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_dir = camera.project_ray_normal(mouse_pos)
	
	var space_state = get_world_3d().direct_space_state
	
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_origin + ray_dir * 1000)
	query.collide_with_areas = false
	query.collide_with_bodies = true
	
	var result = space_state.intersect_ray(query)
	
	if result and result.collider == self:
		return true
	
	return false

func liberar_slots_anteriores():
	for slot in slots_reservados:
		if slot.ocupado_por == self:
			slot.liberar()
	slots_reservados.clear()

func aplicar_material(mat):
	for i in range(mesh_instance.mesh.get_surface_count()):
		#print("setting")
		mesh_instance.set_surface_override_material(i, mat)
		#mesh_instance.material_override = mat
		#mesh_instance.mesh.surface_set_material(0, mat)


func colorNshade():
	var mat
	
	match tier:
		0: mat = preload("res://shaders/bronze_itens.tres")
		1: mat = preload("res://shaders/silver_itens.tres")
		2: mat = preload("res://shaders/gold_itens.tres")
		3: mat = preload("res://shaders/platina_itens.tres")
		4: mat = preload("res://shaders/rainbow_itens.tres")
	aplicar_material(mat)
	#print(mesh_instance)
	#print(mesh_instance.name)

func resizer(_slots):
	match _slots:
		1:
			mesh_instance.mesh = preload("res://materials/smalItem.mesh")
			var createShape = mesh_instance.mesh.create_convex_shape()
			collision_shape.shape = createShape
		2:
			mesh_instance.mesh = preload("res://materials/mediumItem.mesh")
			var createShape = mesh_instance.mesh.create_convex_shape()
			collision_shape.shape = createShape
		3:
			mesh_instance.mesh = preload("res://voxels/bronze_large_item.vox")
			var createShape = mesh_instance.mesh.create_convex_shape()
			collision_shape.shape = createShape
			
	colorNshade()

func existe_item_igual():
	for node in get_tree().get_nodes_in_group("items"):
		if node != self and node.itemName == itemName and node.tier == tier:
			print("encontrou o item")
			print(adding)
			Game.itemUpgrade.emit(node)
			return node
	
	return self

func imager():
	sprite.texture = itemImage
	cooldownUI.texture = itemImage

func _eomesmo(item):
	print("eomesmo start")
	if item != self and item.itemName == itemName and item.tier == tier:
		print(self.name,": é")
		upgrade(item,self)
		return
	else: print(self.name,": É nada")

func upgrade(item,caller):
	if item:
		if item != caller:
			if item.tier !=4:
				#set_process(false)
				var tween = create_tween()
				tween.set_trans(Tween.TRANS_CUBIC)
				tween.set_ease(Tween.EASE_IN_OUT)

				tween.tween_property(
				self,
				"global_position",
				item.global_position,
				0.3
				)

				await tween.finished
				if is_instance_valid(item):
					item.tier +=1
					item.colorNshade()
				adding = false
				print(adding)
				queue_free()
				Game.queueUpgrade()
				#set_process(true)
	else: return

func enemieSlot(esc):
	var slotsT : Array
	for s in get_tree().get_nodes_in_group("slots"):
		slotsT.append(s)
	match slots_necessarios:
			1:
				for c in slotsT:
					print("ID ",c.ID,"OC ",c.ocupado_por)
					if c.ocupado_por == null and c.inventory.name == "enemieGorund" and c.ID == enemieSlotChoice:
						global_position = c.global_position
						return
			2:
				for c in len(slotsT):
					if slotsT[c].ocupado_por == null and slotsT[c].inventory.name == "enemieGorund" and slotsT[c].ID == enemieSlotChoice:
						if slotsT[c-1].ocupado_por == null:
							global_position = slotsT[c].global_position
							return
			3:
				for c in len(slotsT):
					if slotsT[c].ocupado_por == null and slotsT[c].inventory.name == "enemieGorund" and slotsT[c].ID == enemieSlotChoice:
						if slotsT[c-1].ocupado_por == null and slotsT[c+1].ocupado_por == null:
							global_position = slotsT[c].global_position
							return

	pass

func searchSlot():
	var slotsT : Array
	for s in get_tree().get_nodes_in_group("slots"):
		slotsT.append(s)
	match slots_necessarios:
			1:
				for c in slotsT:
					print("ID ",c.ID,"OC ",c.ocupado_por)
					if c.ocupado_por == null and c.inventory.name == "onGorund":
						global_position = c.global_position
						return
					elif c.ocupado_por == null and c.inventory.name == "onStash":
						global_position = c.global_position
						return
			2:
				for c in len(slotsT):
					if slotsT[c].ocupado_por == null and slotsT[c].inventory.name == "onGorund":
						if slotsT[c-1].ocupado_por == null:
							global_position = slotsT[c].global_position
							return
					elif slotsT[c].ocupado_por == null and slotsT[c].inventory.name == "onStash":
						if slotsT[c-1].ocupado_por == null :
							global_position = slotsT[c].global_position
							return
			3:
				for c in len(slotsT):
					if slotsT[c].ocupado_por == null and slotsT[c].inventory.name == "onGorund":
						if slotsT[c-1].ocupado_por == null and slotsT[c+1].ocupado_por == null:
							global_position = slotsT[c].global_position
							return
					elif slotsT[c].ocupado_por == null and slotsT[c].inventory.name == "onStash":
						if slotsT[c-1].ocupado_por == null and slotsT[c+1].ocupado_por == null:
							global_position = slotsT[c].global_position
							return

func spawn_particle(start: Vector3, target: Vector3, color: Color):
	var particle = preload("res://scenes/effects/particle_arc.tscn").instantiate()
	get_tree().current_scene.add_child(particle)
	particle.setup(start, target, color)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	damageUI.visible = false
	shieldUI.visible = false
	burnUI.visible = false
	poisonUI.visible = false
	healUI.visible = false
	cooldownUI.visible = false
	mat2 = mat2.duplicate()
	cooldownUI.material_override = mat2
	Game.startBattle.connect(start_cooldown)
	Game.stopBattle.connect(stop_cooldown)
	for no in get_tree().get_nodes_in_group("enemie"):
		target = no
	for e in effects:
		if e is WeaponEffects:
			damageUI.text = str("[color=red]",e.newDamage,"[/color]")
			damageUI.visible = true
		if e is ShieldEffects:
			shieldUI.text = str("[color=blue]",e.newShield,"[/color]")
			shieldUI.visible = true
		if e is BurnEffects:
			burnUI.text = str("[color=orange]",e.newBurn,"[/color]")
			burnUI.visible = true
		if e is PoisonEffects:
			poisonUI.text = str("[color=purple]",e.newPoison,"[/color]")
			poisonUI.visible = true
		if e is HealEffects:
			healUI.text = str("[color=green]",e.newHeal,"[/color]")
			healUI.visible = true
	print(self.name)
	Game.itemUpgrade.connect(_eomesmo)
	label.text = ""
	add_to_group("items")
	await get_tree().process_frame
	resizer(slots_necessarios)
	imager()
	ultima_posicao_valida = global_position
	global_position.y = base_y
	target_y = base_y
	if spawn == "world":
		pass
	else:
		if enemieItem:
			enemieSlot(enemieSlotChoice)
			await get_tree().create_timer(0.1).timeout
			atualizar_snap()
		else:
			searchSlot()
			await get_tree().create_timer(0.1).timeout
			atualizar_snap()
	#if has_node("../onStash"):
		#$"../onStash".add_item(self)
	if has_node("../Camera3D"):
		camera = $"../Camera3D"
	var nItem = existe_item_igual()
	#Game.queueUpgrade()
	Game.itemUpgrade.emit(nItem, self)
	for t in get_tree().get_nodes_in_group("items"):
		print(t.itemName," - ",t.tier)
