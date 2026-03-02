extends StaticBody3D
@export var camera: Camera3D
@export var float_height := 0.8
@export var base_y := 0.5
@export var return_speed := 6.0
@export var slots_necessarios: int = 1
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
					print("sobe")
			else:
				stop_drag()
				print("desce")

func _process(delta):
	if dragging:
		move_to_mouse()
	# Suaviza subida e descida
		global_position.y = lerp(global_position.y, target_y, return_speed * delta)

func start_drag():
	dragging = true
	target_y = float_height
	drag_plane = Plane(Vector3.UP, float_height)
	print(global_position.y)

func stop_drag():
	dragging = false
	global_position.y = base_y
	print(global_position.y)
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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ultima_posicao_valida = global_position
	global_position.y = base_y
	target_y = base_y
	pass # Replace with function body.
