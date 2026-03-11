extends Node3D
@export var duration := 0.8
@export var height := 1.5
@export var distance := 0.6

var time := 0.0
var start_pos : Vector3
var dir : Vector3


@onready var label = $SubViewport/RichTextLabel

func setup(value:int, direction:Vector3, color:Color, crit:bool, target):
	if color == Color.GREEN or color == Color.BLUE:
		start_pos = target.global_position+Vector3(-1,0,1)
		if crit:
			label.text = str("[wave amp=90]CRIT! +",value,"[/wave]")
		else:
			label.text = str("+",value)
	else:
		start_pos = target.global_position+Vector3(1,0,-1)
		if crit:
			label.text = str("[wave amp=90]CRIT! -",value,"[/wave]")
		else:
			label.text = str("-",value)
	label.modulate = color
	dir = direction.normalized()
	

func _ready():
	start_pos = global_position
	label.visible = false
	dir = Vector3(randf_range(-1,1),0,randf_range(-1,1)).normalized()

func _process(delta):
	label.visible = true
	time += delta
	var t = time / duration

	if t >= 1:
		queue_free()
		return

	# movimento horizontal
	var horizontal = dir * distance * t

	# parabola
	var y = height * 4 * t * (1 - t)

	global_position = start_pos + horizontal + Vector3(0,y,0)

	# escala (pequeno → grande → pequeno)
	var scale_curve = sin(t * PI)
	scale = Vector3.ONE * lerp(0.5,1.4,scale_curve)
