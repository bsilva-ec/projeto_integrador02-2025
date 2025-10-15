# QuizChallenge.gd
extends "res://scripts/challenges/ChallengeBase.gd"

signal continuar_solicitado

var label_texto_pergunta: RichTextLabel
var container_botoes_opcoes: VBoxContainer
var label_feedback: Label
var botao_proximo: Button

var _indice_pergunta_atual: int = 0
var _dados_perguntas: Array = []
var _contador_respostas_corretas: int = 0

func _ready():
	super._ready()
	print("QUIZCHALLENGE CARREGADO!")
	_buscar_nos_quiz()

func _buscar_nos_quiz():
	label_texto_pergunta = find_child("QuestionTextLabel", true, false)
	container_botoes_opcoes = find_child("OptionButtonsContainer", true, false)
	label_feedback = find_child("FeedbackLabel", true, false)
	botao_proximo = find_child("NextButton", true, false)
	
	if botao_proximo and botao_proximo.pressed.is_connected(_on_botao_proximo_pressionado):
		botao_proximo.pressed.disconnect(_on_botao_proximo_pressionado)
	
	if botao_proximo:
		botao_proximo.pressed.connect(_on_botao_proximo_pressionado)
		botao_proximo.visible = false

func _carregar_dados_desafio() -> Dictionary:
	return _dados_desafio

func _configurar_interface_desafio(dados: Dictionary) -> void:
	print("_configurar_interface_desafio()")
	
	if not container_botoes_opcoes:
		printerr("OptionButtonsContainer não encontrado!")
		return
	
	if not dados.has("question") or not dados.has("options") or not dados.has("correct_answer"):
		printerr("Dados da questão incompletos!")
		return
	
	if dados["options"].is_empty():
		printerr("Nenhuma opção fornecida!")
		return
	
	if dados["correct_answer"].is_empty():
		printerr("Resposta correta não fornecida!")
		return
	
	for filho in container_botoes_opcoes.get_children():
		filho.queue_free()
	
	if dados.has("questions"):
		_dados_perguntas = dados["questions"]
	else:
		_dados_perguntas = [{
			"question_text": dados.get("question", ""),
			"options": dados.get("options", []),
			"correct_answer": dados.get("correct_answer", "")
		}]
	
	_indice_pergunta_atual = 0
	_contador_respostas_corretas = 0
	_exibir_pergunta_atual()

func _iniciar_logica_desafio() -> void:
	print("_iniciar_logica_desafio() - QUIZ INICIADO!")
	
	if _dados_perguntas.is_empty():
		printerr("❌ Nenhuma pergunta carregada!")
		return
	
	if not label_texto_pergunta or not container_botoes_opcoes:
		printerr("❌ UI não está pronta!")
		return
	
	print("✅ Tudo pronto, quiz funcionando!")
	_verificar_e_iniciar_quiz()

func _verificar_e_iniciar_quiz():
	print("🎯 Verificando estado do quiz...")
	print("   - Perguntas carregadas: ", _dados_perguntas.size())
	print("   - Índice atual: ", _indice_pergunta_atual)
	print("   - Label de pergunta: ", label_texto_pergunta != null)
	print("   - Container de opções: ", container_botoes_opcoes != null)
	
	# Se por algum motivo a primeira pergunta não foi exibida, exibir agora
	if _indice_pergunta_atual == 0 and _dados_perguntas.size() > 0:
		print("🚀 Exibindo primeira pergunta...")
		_exibir_pergunta_atual()
	else:
		print("📝 Quiz já está em andamento na pergunta ", _indice_pergunta_atual + 1)

func _processar_entrada_jogador(_dados_entrada) -> void:
	pass

func _exibir_pergunta_atual():
	print("Exibindo pergunta: ", _indice_pergunta_atual)
	
	if _indice_pergunta_atual >= _dados_perguntas.size():
		_finalizar_quiz()
		return
	
	var pergunta_atual = _dados_perguntas[_indice_pergunta_atual]
	
	if label_texto_pergunta:
		label_texto_pergunta.text = "Pergunta %d/%d:\n%s" % [
			_indice_pergunta_atual + 1, 
			_dados_perguntas.size(), 
			pergunta_atual["question_text"]
		]
	else:
		printerr("❌ label_texto_pergunta é nulo!")
		return
	
	if container_botoes_opcoes:
		for filho in container_botoes_opcoes.get_children():
			filho.queue_free()
		
		var opcoes = pergunta_atual["options"]
		for i in range(opcoes.size()):
			var botao = Button.new()
			botao.text = opcoes[i]
			botao.custom_minimum_size = Vector2(400, 60)
			botao.pressed.connect(_on_opcao_selecionada.bind(i))
			container_botoes_opcoes.add_child(botao)
	
	if label_feedback:
		label_feedback.text = ""
		label_feedback.modulate = Color.WHITE
	
	if botao_proximo:
		botao_proximo.visible = false
	
	atualizar_barra_progresso(_indice_pergunta_atual + 1, _dados_perguntas.size())

func _on_opcao_selecionada(indice_opcao: int):
	print("Opção selecionada: ", indice_opcao)
	
	var pergunta_atual = _dados_perguntas[_indice_pergunta_atual]
	var resposta_correta = pergunta_atual["correct_answer"]
	var resposta_selecionada = pergunta_atual["options"][indice_opcao]
	
	for botao in container_botoes_opcoes.get_children():
		botao.disabled = true
	
	var acertou = (resposta_selecionada == resposta_correta)
	if acertou:
		_contador_respostas_corretas += 1
		_pontuacao += 10
		if label_feedback:
			label_feedback.text = "Correto! ✅ +10 pontos"
			label_feedback.modulate = Color.GREEN
	else:
		if label_feedback:
			label_feedback.text = "Incorreto! ❌\nResposta: " + resposta_correta
			label_feedback.modulate = Color.RED
	
	if botao_proximo:
		botao_proximo.visible = true
	
	print("CENA PARADA - Esperando continuar...")
	await continuar_solicitado
	print("CENA CONTINUANDO...")
	
	_ir_para_proxima_pergunta()

func _on_botao_proximo_pressionado():
	print("🎯 Continuar pressionado")
	continuar_solicitado.emit()

func _ir_para_proxima_pergunta():
	print("🎯 Preparando próxima questão...")
	_indice_pergunta_atual += 1
	
	if container_botoes_opcoes:
		for filho in container_botoes_opcoes.get_children():
			filho.queue_free()
	
	_exibir_pergunta_atual()

func _finalizar_quiz():
	print("🎯 Quiz finalizado! Acertos: ", _contador_respostas_corretas, "/", _dados_perguntas.size())
	
	var precisao = float(_contador_respostas_corretas) / _dados_perguntas.size()
	var sucesso = _contador_respostas_corretas > 0
	
	var pontuacao_base = _contador_respostas_corretas * 10
	var bonus_precisao = int(pontuacao_base * precisao)
	_pontuacao = pontuacao_base + bonus_precisao
	
	_on_desafio_concluido(sucesso, _pontuacao, {
		"acertos": _contador_respostas_corretas,
		"total_perguntas": _dados_perguntas.size(),
		"precisao_porcentagem": int(precisao * 100)
	})

func _exit_tree():
	if botao_proximo and botao_proximo.pressed.is_connected(_on_botao_proximo_pressionado):
		botao_proximo.pressed.disconnect(_on_botao_proximo_pressionado)
