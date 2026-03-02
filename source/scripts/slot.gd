extends Area3D

@export var ID: int
@export var inventory: Node

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.has_method("registrar_slot"):
		body.registrar_slot(self)
		print("entrou em: ",ID)

func _on_body_exited(body):
	if body.has_method("remover_slot"):
		body.remover_slot(self)
		print("saiu de: ",ID)
