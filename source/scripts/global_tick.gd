extends Node

signal tick
signal half_tick

var seconds := 0
var _accumulator := 0.0
var _half_toggle := false

func _process(delta):
	#print("ticking: ",_accumulator," | ",seconds)
	if Game.tickEnable:
		_accumulator += delta
		
		while _accumulator >= 0.5:
			_accumulator -= 0.5
			  
			emit_signal("half_tick")
			
			_half_toggle = !_half_toggle
			
			if !_half_toggle:
				seconds += 1
				emit_signal("tick")
