# MainMenu.gd
extends Control

func _ready():
	# Conecta os sinais dos botões às funções. Você pode fazer isso pelo editor também.
	$MenuOptions/PlayButton.pressed.connect(_on_play_button_pressed)
	$MenuOptions/OptionsButton.pressed.connect(_on_options_button_pressed)
	$MenuOptions/QuitButton.pressed.connect(_on_quit_button_pressed)

func _on_play_button_pressed():
	# Muda para a cena de seleção de aluno.
	get_tree().change_scene_to_file("res://scenes/UI/StudentSelection.tscn")

func _on_options_button_pressed():
	print("Tela de Opções ainda não implementada.")
	# get_tree().change_scene_to_file("res://scenes/menus/Options.tscn")

func _on_quit_button_pressed():
	# Fecha o jogo.
	get_tree().quit()
