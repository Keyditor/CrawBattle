extends Node3D


var start_pos: Vector3
var target_pos: Vector3

var duration := 0.6
var height := 1.5
var time := 0.0

@onready var mesh := $MeshInstance3D
@onready var trail:GPUParticles3D= $GPUParticles3D
@onready var tail3d: GPUTrail3D = $MeshInstance3D/GPUTrail3D

func criar_ramp(cor: Color) -> Gradient:
	var ramp := Gradient.new()
	ramp.add_point(0.0, cor)
	ramp.add_point(1.0, Color(cor.r, cor.g, cor.b, 0.0))
	return ramp

func setup(start: Vector3, target: Vector3, color: Color, arc_height := 1.5, life := 0.6):
	start_pos = start
	target_pos = target
	height = arc_height
	duration = life
	
	global_position = start_pos
	var mat2 : StandardMaterial3D = preload("res://materials/trail.tres")
	mat2.albedo_color = color
	trail.draw_pass_1.surface_set_material(0,mat2)
	tail3d.color_ramp.gradient = criar_ramp(color)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.emission_enabled = true
	mat.emission = color
	mesh.material_override = mat

func _process(delta):
	time += delta
	var t = time / duration
	
	if t >= 1.0:
		queue_free()
		return
	# easing (rápido → lento)
	t = ease(t, -2.0)
	
	var pos = start_pos.lerp(target_pos, t)
	
	# parábola
	pos.y += height * 4 * (t * (1 - t))
	
	global_position = pos
