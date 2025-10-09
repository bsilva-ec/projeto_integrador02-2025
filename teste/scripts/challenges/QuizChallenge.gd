# QuizChallenge.gd
extends "res://scripts/challenges/ChallengeBase.gd" # Herda da classe de desafio

@onready var question_text_label: Label = %QuestionTextLabel
@onready var option_buttons_container: VBoxContainer = %OptionButtonsContainer # Um contêiner para os botões de opção
@onready var feedback_label: Label = %FeedbackLabel # Para mostrar "Correto!" ou "Incorreto!"

var _current_question_index: int = 0
var _questions_data: Array = []
var _correct_answers_count: int = 0
var _current_question_attempts: int = 0

func _ready():
	super._ready()
	# Conectar os sinais dos botões de opção se eles forem criados dinamicamente
	# Ou conectar se eles forem estáticos e já existirem na cena
	# For exemplo, se você tiver 4 botões, você os conectaria aqui:
	# %OptionButton1.pressed.connect(func(): _process_player_input(0))
	# %OptionButton2.pressed.connect(func(): _process_player_input(1))
	# ...

# Métodos Sobrescritos da ChallengeBase

func _load_challenge_data() -> Dictionary:
	# A lógica de carregamento de JSON já está na init_challenge da base
	# Apenas retornar os dados que a base já carregou
	return _challenge_data

func _setup_ui_for_challenge(data: Dictionary) -> void:
	_questions_data = data.get("question", [])
	if _questions_data.is_empty():
		printerr("QuizChallenge: No questions found in challenge data.")
		request_exit_to_map.emit()
		return
	
	# Limpa botões antigos, caso tenha
	for child in option_buttons_container.get_children():
		child.queue_free()
	
	# Cria os botões de opção dinamicamente
	for i in range(_questions_data[0].get("options", []).size()):
		var button = Button.new()
		button.text = "Opção " + str(i+1) # Texto placeholder, será atualizado
		button.add_theme_font_size_override("font_size", 30) #Exemplo de estilo
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		button.pressed.connect(func(_idx = i): _process_player_input(_idx))
		option_buttons_container.add_child(button)
	
	_current_question_index = 0
	_correct_answers_count = 0
	_current_question_attempts = 0
	_display_current_question()

func _start_challenge_logic() -> void:
	# Nada de especial para iniciar além do setup da UI
	pass

func _process_player_input(selected_option_index: int) -> void:
	_current_question_attempts += 1
	
	var current_question = _questions_data[_current_question_index]
	var correct_index = current_question.get("correct_answer_index")
	
	# Desabilita botões para evitar cliques múltiplos
	for button in option_buttons_container.get_children():
		button.disabled = true
	
	if selected_option_index == correct_index:
		_correct_answers_count += 1
		_score += 10 # Exemplo de pontuação
		feedback_label.text = "Correto!"
		feedback_label.modulate = Color.GREEN # Feedback visual
		# Animação ou som de sucesso
		print("Quiz: Correct answer!")
		await get_tree().create_timer(1.0).timeout # Espera 1 segundo
		_go_to_next_question()
	else:
		feedback_label.text = "Incorreto!"
		feedback_label.modulate = Color.RED # Feedback visual
		# Animação ou som de erro
		print("Quiz: Incorrect answer!")
		await get_tree().create_timer(1.5).timeout # Espera 1.5 segundos
		# Se quiser limitar tentativas ou mostrar a correta depois de X erros
		# if _current_question_attempts >= 2:
		#    feedback_label.text = "A resposta correta era: " + current_question.options[correct_index]
		#    await get_tree().create_timer(2.0).timeout
		_go_to_next_question()
	
	feedback_label.text = "" # Limpa feedback
	_current_question_attempts = 0 # Reinicia tentativas para próxima pergunta

# Métodos específicos do quiz

func _display_current_question() -> void:
	if _current_question_index >= _questions_data.size():
		_finish_quiz()
		return
	
	var question = _questions_data[_current_question_index]
	question_text_label.text = question.get("question_text", "Erro: Pergunta não encontrada.")
	
	var options = question.get("options", [])
	for i in range(option_buttons_container.get_child_count()):
		var button = option_buttons_container.get_child(i) as Button
		if i < options.size():
			button.text = options[i]
			button.visible = true
			button.disabled = false # Reabilita botões
		else: 
			button.visible = false # Esconde botões extras
	
	update_progress_bar(_current_question_index + 1, _questions_data.size())

func _go_to_next_question() -> void:
	_current_question_index += 1
	_display_current_question()

func _finish_quiz() -> void:
	var is_sucess = _correct_answers_count >= (_questions_data.size() * 0.7) # Ex: 70% de acertos para sucesso
	_on_challenge_completed(is_sucess, _score, {"correct_count": _correct_answers_count, "total_questions": _questions_data.size()})
