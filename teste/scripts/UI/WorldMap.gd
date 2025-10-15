# WorldMap.gd
extends Control

var temas = []
var tema_atual = 0

func _ready():
	print("=== MAPA MUNDIAL ===")
	configurar_interface()
	carregar_temas()
	
	# Verificar se há uma fase em andamento
	if SceneManager.tem_mais_desafios():
		print("Retomando fase em andamento...")
		iniciar_proximo_desafio()

func configurar_interface():
	# Atualizar info do jogador
	var label_nome = find_child("StudentNameLabel", true, false)
	var label_pontuacao = find_child("ScoreLabel", true, false)
	
	if GameManager.jogador_atual:
		label_nome.text = "Jogador: " + GameManager.jogador_atual.nome
		label_pontuacao.text = "Pontuação: " + str(GameManager.obter_pontuacao_jogador())
		print("Pontuação no mapa: ", GameManager.obter_pontuacao_jogador())

func carregar_temas():
	var container_temas = find_child("ThemeViewer", true, false)
	
	if not container_temas:
		printerr("Container de temas não encontrado!")
		return
	
	# Coletar todos os temas
	temas.clear()
	for tema in container_temas.get_children():
		temas.append(tema)
	
	print("Temas carregados: ", temas.size())
	mostrar_tema_atual()

func mostrar_tema_atual():
	# Esconder todos os temas
	for i in range(temas.size()):
		temas[i].visible = (i == tema_atual)
	
	# Atualizar título
	var label_titulo = find_child("ThemeTitleLabel", true, false)
	if label_titulo and tema_atual < temas.size():
		label_titulo.text = temas[tema_atual].name.replace("Theme_", "").replace("_", " ")

func _on_botao_proximo_tema():
	tema_atual = (tema_atual + 1) % temas.size()
	mostrar_tema_atual()
	print("Próximo tema: ", tema_atual)

func _on_botao_tema_anterior():
	tema_atual = tema_atual - 1
	if tema_atual < 0:
		tema_atual = temas.size() - 1
	mostrar_tema_atual()
	print("Tema anterior: ", tema_atual)

func _on_botao_fase_pressionado():
	var botao = get_viewport().gui_get_focus_owner()
	
	if botao and botao is Button:
		var fase_id = botao.name
		print("Iniciando fase: ", fase_id)
		
		GameManager.fase_atual = fase_id
		iniciar_fase(fase_id)

func iniciar_fase(fase_id: String):
	print("Iniciando fase: ", fase_id)
	
	var dados_fase = carregar_dados_fase()
	
	if not dados_fase.has(fase_id):
		printerr("Fase não encontrada: ", fase_id)
		return
	
	var fase_data = dados_fase[fase_id]
	
	if fase_data["challenges"].is_empty():
		printerr("Nenhum desafio na fase: ", fase_id)
		return
	
	print("Fase carregada: ", fase_data["title"])
	print("   - Total desafios: ", fase_data["challenges"].size())
	
	# WorldMap prepara os dados e passa para SceneManager
	var dados_preparados = {
		"fase_data": fase_data,
		"challenges": fase_data["challenges"],
		"title": fase_data["title"]
	}
	
	SceneManager.preparar_fase(dados_preparados, fase_id)
	
	# Iniciar o primeiro desafio
	iniciar_proximo_desafio()

func iniciar_proximo_desafio():
	print("Iniciando próximo desafio...")
	
	var proximo_desafio = SceneManager.obter_proximo_desafio()
	if proximo_desafio.is_empty():
		print("FASE COMPLETA - Todos os desafios concluídos!")
		SceneManager.limpar_dados()
		return
	
	var tipo_desafio = proximo_desafio["type"]
	var caminho_cena = ""
	var dados_completos = {}
	
	print("Tipo do próximo desafio: ", tipo_desafio)
	print("ID do próximo desafio: ", proximo_desafio["id"])
	
	match tipo_desafio:
		"quiz":
			caminho_cena = "res://scenes/challenges/QuizChallenge.tscn"
			
			# Carregar dados do quiz
			var questao_atual = {
				"question_text": carregar_pergunta_quiz(proximo_desafio["id"]),
				"options": carregar_opcoes_quiz(proximo_desafio["id"]),
				"correct_answer": carregar_resposta_quiz(proximo_desafio["id"])
			}
			
			dados_completos = {
				"id": proximo_desafio["id"],
				"type": "quiz",
				"title": "Quiz",
				"instructions": "Leia a pergunta e selecione a alternativa correta.",
				"questions": [questao_atual]
			}
			print("Questão carregada: ", proximo_desafio["id"])
			
		"relate":
			caminho_cena = "res://scenes/challenges/RelateChallenge.tscn"
			dados_completos = carregar_dados_relate(proximo_desafio["id"])
			if dados_completos.is_empty():
				printerr("Não foi possível carregar dados do relate")
				return
				
			dados_completos["title"] = "Relacione"
			dados_completos["instructions"] = "Conecte os itens correspondentes"
			dados_completos["type"] = "relate"
			print("Dados do relate carregados: ", proximo_desafio["id"])
			
		_:
			printerr("Tipo de desafio desconhecido: ", tipo_desafio)
			return
	
	if caminho_cena.is_empty():
		printerr("Caminho de cena vazio!")
		return
	
	print("Carregando: ", caminho_cena)
	
	# WorldMap prepara os dados e SceneManager só armazena
	SceneManager.preparar_desafio_especifico(dados_completos)
	get_tree().change_scene_to_file(caminho_cena)

func carregar_dados_fase() -> Dictionary:
	var arquivo = FileAccess.open("res://data/levels/fases.json", FileAccess.READ)
	if arquivo:
		var conteudo = arquivo.get_as_text()
		arquivo.close()
		var dados = JSON.parse_string(conteudo)
		if dados is Dictionary:
			print("Dados das fases carregados com sucesso")
			return dados
		else:
			printerr("Erro ao parsear JSON das fases")
	
	printerr("Arquivo de fases não encontrado ou vazio")
	return {}

func carregar_dados_relate(relate_id: String) -> Dictionary:
	var arquivo = FileAccess.open("res://data/levels/relate.json", FileAccess.READ)
	if arquivo:
		var dados = JSON.parse_string(arquivo.get_as_text())
		arquivo.close()
		if dados is Dictionary and dados.has(relate_id):
			print("Dados do relate carregados: ", relate_id)
			return dados[relate_id]
		else:
			printerr("Relate não encontrado: ", relate_id)
	
	printerr("Arquivo relate.json não encontrado")
	return {}

func carregar_pergunta_quiz(quiz_id: String) -> String:
	# Carregar do arquivo quiz.json
	var arquivo = FileAccess.open("res://data/levels/quiz.json", FileAccess.READ)
	if arquivo:
		var dados = JSON.parse_string(arquivo.get_as_text())
		arquivo.close()
		var pergunta = dados.get(quiz_id, {}).get("question", "Pergunta não encontrada")
		print("Pergunta carregada para ", quiz_id, ": ", pergunta)
		return pergunta
	return "Pergunta não carregada"

func carregar_opcoes_quiz(quiz_id: String) -> Array:
	var arquivo = FileAccess.open("res://data/levels/quiz.json", FileAccess.READ)
	if arquivo:
		var dados = JSON.parse_string(arquivo.get_as_text())
		arquivo.close()
		var opcoes = dados.get(quiz_id, {}).get("options", ["Opção A", "Opção B"])
		print("Opções carregadas para ", quiz_id, ": ", opcoes)
		return opcoes
	return ["Opção A", "Opção B"]

func carregar_resposta_quiz(quiz_id: String) -> String:
	var arquivo = FileAccess.open("res://data/levels/quiz.json", FileAccess.READ)
	if arquivo:
		var dados = JSON.parse_string(arquivo.get_as_text())
		arquivo.close()
		var resposta = dados.get(quiz_id, {}).get("correct_answer", "Opção A")
		print("Resposta correta para ", quiz_id, ": ", resposta)
		return resposta
	return "Opção A"

func _on_botao_voltar_pressionado():
	print("Voltando para seleção de jogador...")
	SceneManager.limpar_dados()
	get_tree().change_scene_to_file("res://scenes/UI/StudentSelection.tscn")

func _on_botao_tema_anterior_pressionado() -> void:
	_on_botao_tema_anterior()
