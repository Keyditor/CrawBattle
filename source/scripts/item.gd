extends MeshInstance3D
@export var camera: Camera3D
@export var float_height := 0.8
@export var base_y := 0.5
@export var return_speed := 6.0
var drag_plane : Plane
var dragging := false
var is_floating := false
var target_y := base_y

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				start_drag()
				print("sobe")
			else:
				stop_drag()
				print("desce")

func _process(delta):
	if dragging:
		move_to_mouse()
	# Suaviza subida e descida
		global_position.y = target_y #lerp(global_position.y, target_y, return_speed * delta)

func start_drag():
	dragging = true
	target_y = float_height
	drag_plane = Plane(Vector3.UP, float_height)
	print(global_position.y)

func stop_drag():
	dragging = false
	global_position.y = base_y
	print(global_position.y)

func move_to_mouse():
	var mouse_pos = get_viewport().get_mouse_position()
	
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_dir = camera.project_ray_normal(mouse_pos)
	
	var hit = drag_plane.intersects_ray(ray_origin, ray_dir)
	
	if hit:
		global_position.x = hit.x
		global_position.z = hit.z

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_position.y = base_y
	target_y = base_y
	pass # Replace with function body.
