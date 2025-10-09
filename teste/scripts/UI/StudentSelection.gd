# StudentSelection.gd
extends Control

# Referências para os nós que vamos manipular
@onready var student_list_container = $VBoxContainer/ScrollContainer/StudentListContainer
@onready var new_student_input = $VBoxContainer/HBoxContainer/NewStudentInput
@onready var feedback_label = $VBoxContainer/FeedbackLabel
@onready var create_button = $VBoxContainer/HBoxContainer/CreateStudentButton


func _ready():
	# Assim que a cena carregar, preenchemos a lista com os alunos existentes
	_populate_student_list()
	
	# Conecta o sinal do botão de criar. Isso também pode ser feito pelo editor.
	create_button.pressed.connect(_on_create_student_button_pressed)
	# Foca no campo de texto para o jogador já poder digitar
	new_student_input.grab_focus()


# Função para limpar e preencher a lista de alunos
func _populate_student_list():
	# 1. Limpa qualquer botão que já exista para não duplicar
	for child in student_list_container.get_children():
		child.queue_free()
		
	# 2. Pega a lista de todos os dados dos alunos do GameManager
	var students = GameManager.get_all_students_for_dashboard()
	
	# 3. Cria um botão para cada aluno
	if students.is_empty():
		feedback_label.text = "Nenhum aluno cadastrado. Crie um novo perfil!"
	else:
		feedback_label.text = "Selecione seu perfil ou crie um novo."
		for student_data in students:
			var student_name = student_data.get("name", "Nome Desconhecido")
			var button = Button.new()
			button.text = student_name
			# Define um tamanho mínimo para os botões ficarem uniformes
			button.custom_minimum_size = Vector2(250, 50) 
			# Conecta o sinal 'pressed' deste botão à função de seleção
			button.pressed.connect(_on_student_button_pressed.bind(student_name))
			student_list_container.add_child(button)


# Chamado quando o botão "Criar e Entrar" é pressionado
func _on_create_student_button_pressed():
	var student_name = new_student_input.text.strip_edges() # strip_edges() remove espaços em branco
	
	if student_name.is_empty():
		feedback_label.text = "O nome não pode estar em branco."
		return
		
	# A função create_new_student_profile retorna 'true' se for sucesso
	if GameManager.create_new_student_profile(student_name):
		feedback_label.text = str("Bem-vindo(a), ", student_name, "!")
		new_student_input.clear()
		_populate_student_list() # Atualiza a lista para mostrar o novo aluno
		# Opcional: já logar com o aluno recém-criado
		_on_student_button_pressed(student_name)
	else:
		feedback_label.text = "Este nome já existe. Tente outro."
		

# Chamado quando um dos botões de aluno (da lista) é pressionado
func _on_student_button_pressed(student_name: String):
	feedback_label.text = str("Carregando perfil de ", student_name, "...")
	
	# Carrega os dados do aluno no GameManager
	if GameManager.load_student_profile(student_name):
		# Se carregou com sucesso, vai para o mapa
		get_tree().change_scene_to_file("res://scenes/menus/WorldMap.tscn")
	else:
		# Isso não deveria acontecer se o botão foi criado corretamente, mas é bom ter
		feedback_label.text = str("Erro ao carregar o perfil de ", student_name, ".")
