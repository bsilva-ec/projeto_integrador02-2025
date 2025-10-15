# StudentSelection.gd
extends Control

var container_jogadores: VBoxContainer
var entrada_novo: LineEdit
var botao_criar: Button
var label_feedback: Label

func _ready():
	print("=== SELEÇÃO DE JOGADOR ===")
	container_jogadores = find_child("StudentListContainer", true, false)
	entrada_novo = find_child("NewStudentInput", true, false) 
	botao_criar = find_child("CreateStudentButton", true, false)
	label_feedback = find_child("FeedbackLabel", true, false)
	carregar_lista_jogadores()

func carregar_lista_jogadores():
	var container = find_child("StudentListContainer", true, false)
	var feedback = find_child("FeedbackLabel", true, false)
	
	if not container:
		printerr("Container de jogadores não encontrado!")
		return
	
	# Limpar lista
	for filho in container.get_children():
		filho.queue_free()
	
	var jogadores = GameManager.obter_todos_jogadores()
	
	if jogadores.is_empty():
		feedback.text = "Nenhum jogador cadastrado. Crie um novo!"
	else:
		feedback.text = "Selecione seu jogador:"
		
		for jogador in jogadores:
			var botao = Button.new()
			botao.text = jogador.nome
			botao.custom_minimum_size = Vector2(250, 50)
			botao.pressed.connect(selecionar_jogador.bind(jogador.nome))
			container.add_child(botao)

func selecionar_jogador(nome: String):
	print("Selecionando jogador: ", nome)
	
	if GameManager.carregar_jogador(nome):
		print("Indo para o mapa...")
		get_tree().change_scene_to_file("res://scenes/UI/WorldMap.tscn")
	else:
		printerr("Falha ao carregar jogador")

func _on_botao_criar_pressionado():
	var entrada = find_child("NewStudentInput", true, false)
	var feedback = find_child("FeedbackLabel", true, false)
	
	var nome = entrada.text.strip_edges()
	
	if nome.is_empty():
		feedback.text = "Digite um nome!"
		return
	
	if GameManager.criar_jogador(nome):
		feedback.text = "Jogador criado: " + nome
		entrada.text = ""
		carregar_lista_jogadores()
	else:
		feedback.text = "Nome já existe!"
