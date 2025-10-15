# MainMenu.gd
extends Control

func _ready():
	print("=== MENU INICIAL ===")

func _on_botao_jogar_pressionado():
	print("Iniciando jogo...")
	get_tree().change_scene_to_file("res://scenes/UI/StudentSelection.tscn")

func _on_botao_opcoes_pressionado():
	print("Opções (não implementado)")

func _on_botao_creditos_pressionado():
	print("Créditos (não implementado)")

func _on_botao_sair_pressionado():
	print("Saindo do jogo...")
	get_tree().quit()
