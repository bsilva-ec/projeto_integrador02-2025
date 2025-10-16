# DrawingCanvas.gd
extends Control

# Referência para o RelateChallenge
var relate_challenge: Node = null

func set_relate_challenge(challenge: Node):
	relate_challenge = challenge
	print("DrawingCanvas conectado ao RelateChallenge")

func _draw():
	if relate_challenge and relate_challenge.has_method("_on_area_desenho_draw"):
		relate_challenge._on_area_desenho_draw()

func _input(event):
	# Repassar eventos de input para o RelateChallenge
	if relate_challenge and relate_challenge.has_method("_on_area_desenho_input"):
		relate_challenge._on_area_desenho_input(event)
