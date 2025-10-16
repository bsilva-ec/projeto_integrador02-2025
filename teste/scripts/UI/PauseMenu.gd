# PauseMenu.gd
extends CanvasLayer

signal retomado
signal reiniciar_desafio
signal sair_para_mapa

func _ready():
	print("Menu de Pause carregado")
	
	# Conectar botões
	var botao_retomar = find_child("ResumeButton", true, false)
	var botao_reiniciar = find_child("RestartButton", true, false)
	var botao_sair = find_child("QuitToMapButton", true, false)
	
	if botao_retomar:
		botao_retomar.pressed.connect(_on_retomar_pressionado)
	if botao_reiniciar:
		botao_reiniciar.pressed.connect(_on_reiniciar_pressionado)
	if botao_sair:
		botao_sair.pressed.connect(_on_sair_pressionado)

func _on_retomar_pressionado():
	print("Retomando jogo...")
	retomado.emit()
	queue_free()

func _on_reiniciar_pressionado():
	print("Reiniciando desafio...")
	reiniciar_desafio.emit()
	queue_free()

func _on_sair_pressionado():
	print("Saindo para o mapa...")
	sair_para_mapa.emit()
	queue_free()

func _input(event):
	# Fechar com ESC
	if event.is_action_pressed("ui_cancel"):
		_on_retomar_pressionado()
