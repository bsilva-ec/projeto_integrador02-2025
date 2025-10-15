# MainMenu.gd
extends Control

var botao_jogar: Button
var botao_opcoes: Button
var botao_sair: Button

func _ready():
	_buscar_botoes()
	_conectar_sinais()

func _buscar_botoes():
	botao_jogar = find_child("PlayButton", true, false)
	botao_opcoes = find_child("OptionsButton", true, false)
	botao_sair = find_child("QuitButton", true, false)

func _conectar_sinais():
	if botao_jogar:
		botao_jogar.pressed.connect(_on_botao_jogar_pressionado)
	if botao_opcoes:
		botao_opcoes.pressed.connect(_on_botao_opcoes_pressionado)
	if botao_sair:
		botao_sair.pressed.connect(_on_botao_sair_pressionado)

func _on_botao_jogar_pressionado():
	get_tree().change_scene_to_file("res://scenes/UI/StudentSelection.tscn")

func _on_botao_opcoes_pressionado():
	print("Tela de Opções ainda não implementada.")

func _on_botao_sair_pressionado():
	get_tree().quit()
