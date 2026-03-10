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

func _input(event):
	if event is InputEventMouseButton:
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
		spawn_particle(
			self.global_position,
			Vector3(8.5,0,-5.6),
			Color.DARK_ORANGE
		)
	if Game.checkUpgrade and tier != 4:
		print(self.name,": dando upgrade consecutivo")
		var uItem = existe_item_igual()
		if uItem!=self: Game.itemUpgrade.emit(uItem, self); Game.checkUpgrade = false
		print("desligando upgrade")
	if !slots_reservados and !adding:
		label.text = "Posicione o item em um slot vazio!"
	else:
		label.text = ""
	if dragging:
		move_to_mouse()
	# Suaviza subida e descida
		global_position.y = lerp(global_position.y, target_y, return_speed * delta)

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

func followto(_side): #futura função para reorganização
	pass

func look_free_slot(): #futura função para reoorganização
	pass

func move_to_mouse():
	var mouse_pos = get_viewport().get_mouse_position()
	
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_dir = camera.project_ray_normal(mouse_pos)
	
	var hit = drag_plane.intersects_ray(ray_origin, ray_dir)
	
	if hit:
		global_position.x = hit.x
		global_position.z = hit.z

func registrar_slot(slot):
	if slot not in slots_encostando:
		slots_encostando.append(slot)
		#atualizar_snap()

func remover_slot(slot):
	slots_encostando.erase(slot)
	#atualizar_snap()

func atualizar_snap():
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

func spawn_particle(start: Vector3, target: Vector3, color: Color):
	var particle = preload("res://scenes/effects/particle_arc.tscn").instantiate()
	get_tree().current_scene.add_child(particle)
	particle.setup(start, target, color)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
	#if has_node("../onStash"):
		#$"../onStash".add_item(self)
	if has_node("../Camera3D"):
		camera = $"../Camera3D"
	var nItem = existe_item_igual()
	#Game.queueUpgrade()
	Game.itemUpgrade.emit(nItem, self)
	for t in get_tree().get_nodes_in_group("items"):
		print(t.itemName," - ",t.tier)
