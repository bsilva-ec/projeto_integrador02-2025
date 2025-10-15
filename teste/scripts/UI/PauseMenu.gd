# PauseMenu.gd
extends CanvasLayer

signal retomar_jogo
signal reiniciar_fase
signal sair_para_mapa

func _ready():
	_conectar_botoes_locais()

func _conectar_botoes_locais():
	var botao_retomar = find_child("ResumeButton", true, false)
	var botao_reiniciar = find_child("RestartButton", true, false)
	var botao_sair_mapa = find_child("QuitToMapButton", true, false)
	
	if botao_retomar:
		botao_retomar.pressed.connect(_on_botao_retomar_pressionado)
	if botao_reiniciar:
		botao_reiniciar.pressed.connect(_on_botao_reiniciar_pressionado)
	if botao_sair_mapa:
		botao_sair_mapa.pressed.connect(_on_botao_sair_mapa_pressionado)

func _on_botao_retomar_pressionado():
	get_tree().paused = false
	retomar_jogo.emit()
	queue_free()

func _on_botao_reiniciar_pressionado():
	get_tree().paused = false
	reiniciar_fase.emit()
	queue_free()

func _on_botao_sair_mapa_pressionado():
	get_tree().paused = false
	sair_para_mapa.emit()
	queue_free()

func _input_nao_tratado(evento):
	if evento.is_action_pressed("ui_cancel"):
		_on_botao_retomar_pressionado()
