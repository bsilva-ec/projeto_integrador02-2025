# StudentSelection.gd
extends Control

var container_lista_alunos: VBoxContainer
var entrada_novo_aluno: LineEdit
var botao_criar: Button
var label_feedback: Label

func _ready():
	_buscar_nos_interface()
	_preencher_lista_alunos()
	
	if entrada_novo_aluno:
		entrada_novo_aluno.grab_focus()

func _buscar_nos_interface():
	container_lista_alunos = find_child("StudentListContainer", true, false)
	entrada_novo_aluno = find_child("NewStudentInput", true, false)
	botao_criar = find_child("CreateStudentButton", true, false)
	label_feedback = find_child("FeedbackLabel", true, false)
	
	if not container_lista_alunos:
		printerr("ERRO CRÍTICO: StudentListContainer não encontrado!")

func _preencher_lista_alunos():
	for filho in container_lista_alunos.get_children():
		filho.queue_free()
	
	var alunos = GameManager.obter_todos_alunos()
	
	if alunos.is_empty():
		label_feedback.text = "Nenhum aluno cadastrado. Crie um novo perfil!"
	else:
		label_feedback.text = "Selecione seu perfil ou crie um novo."
		for dados_aluno in alunos:
			var nome_aluno = dados_aluno.get("name", "Nome Desconhecido")
			var botao = Button.new()
			botao.text = nome_aluno
			botao.custom_minimum_size = Vector2(250, 50)
			botao.pressed.connect(_on_botao_aluno_pressionado.bind(nome_aluno))
			container_lista_alunos.add_child(botao)

func _on_botao_criar_aluno_pressionado():
	var label_feedback_atual = find_child("FeedbackLabel", true, false)
	var entrada_aluno_atual = find_child("NewStudentInput", true, false)
	
	var nome_aluno = entrada_aluno_atual.text.strip_edges() if entrada_aluno_atual else ""
	
	if nome_aluno.is_empty():
		if label_feedback_atual:
			label_feedback_atual.text = "O nome não pode estar em branco."
		return
	
	if GameManager.criar_novo_perfil_aluno(nome_aluno):
		if label_feedback_atual:
			label_feedback_atual.text = str("Bem-vindo(a), ", nome_aluno, "!")
		if entrada_aluno_atual:
			entrada_aluno_atual.clear()
		_preencher_lista_alunos()
	else:
		if label_feedback_atual:
			label_feedback_atual.text = "Este nome já existe. Tente outro."

func _on_botao_aluno_pressionado(nome_aluno: String):
	print("Tentando carregar estudante: ", nome_aluno)
	
	if GameManager.carregar_perfil_aluno(nome_aluno):
		print("Estudante carregado com sucesso, indo para o mapa...")
		get_tree().change_scene_to_file("res://scenes/UI/WorldMap.tscn")
	else:
		printerr("FALHA ao carregar estudante: ", nome_aluno)
