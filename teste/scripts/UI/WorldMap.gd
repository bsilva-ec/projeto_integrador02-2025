# WorldMap.gd
extends Control

var label_nome_aluno: Label
var label_pontuacao: Label
var label_titulo_tema: Label
var visualizador_temas: Control
var botao_anterior: TextureButton
var botao_proximo: TextureButton

var temas: Array = []
var indice_tema_atual: int = 0
var dados_fases: Dictionary = {}

func _ready():
	_buscar_todos_nos()
	_carregar_dados_fases()
	_configurar_botoes_fase_existentes()
	_atualizar_info_aluno()
	_atualizar_exibicao_tema()

func _carregar_dados_fases():
	var arquivo = FileAccess.open("res://data/levels/fases.json", FileAccess.READ)
	if arquivo:
		var conteudo = arquivo.get_as_text()
		arquivo.close()
		
		print("Conteúdo do arquivo fases.json:")
		print(conteudo)
		
		var json = JSON.new()
		var erro = json.parse(conteudo)
		if erro == OK:
			dados_fases = json.data
			print("Dados das fases carregados com sucesso: ", dados_fases)
		else:
			printerr("Erro ao parsear JSON das fases: ", json.get_error_message())
	else:
		printerr("Arquivo de fases não encontrado")

func _configurar_botoes_fase_existentes():
	temas.clear()
	
	for no_tema in visualizador_temas.get_children():
		temas.append(no_tema)
		
		for botao_fase in no_tema.get_children():
			if botao_fase is Button:
				var id_fase = botao_fase.name
				var dados_fase = dados_fases.get(id_fase, {})
				
				if dados_fase.has("title"):
					botao_fase.text = dados_fase["title"]
				
				if GameManager.fase_foi_concluida(id_fase):
					botao_fase.add_theme_color_override("font_color", Color.GREEN)
					botao_fase.text += " ✓"

func _buscar_todos_nos():
	label_nome_aluno = find_child("StudentNameLabel", true, false)
	label_pontuacao = find_child("ScoreLabel", true, false)
	label_titulo_tema = find_child("ThemeTitleLabel", true, false)
	visualizador_temas = find_child("ThemeViewer", true, false)
	botao_anterior = find_child("PreviousThemeButton", true, false)
	botao_proximo = find_child("NextThemeButton", true, false)
	
	if not visualizador_temas:
		visualizador_temas = $StudentHUD/HBoxContainer/ThemeViewer if has_node("StudentHUD/HBoxContainer/ThemeViewer") else null
	if not botao_anterior:
		botao_anterior = $StudentHUD/HBoxContainer/Background/PreviousThemeButton if has_node("StudentHUD/HBoxContainer/Background/PreviousThemeButton") else null
	if not botao_proximo:
		botao_proximo = $StudentHUD/HBoxContainer/Background/NextThemeButton if has_node("StudentHUD/HBoxContainer/Background/NextThemeButton") else null

func _atualizar_info_aluno():
	if GameManager.jogador_atual:
		label_nome_aluno.text = "Aluno: " + GameManager.jogador_atual.student_name
		label_pontuacao.text = "Pontuação: " + str(GameManager.jogador_atual.pontuacao_total)

func _atualizar_exibicao_tema():
	for i in temas.size():
		var no_tema = temas[i]
		if i == indice_tema_atual:
			no_tema.visible = true
			label_titulo_tema.text = no_tema.name.replace("Theme_", "").replace("_", " ")
		else:
			no_tema.visible = false

func _on_botao_proximo_tema_pressionado():
	indice_tema_atual = (indice_tema_atual + 1) % temas.size()
	_atualizar_exibicao_tema()

func _on_botao_tema_anterior_pressionado():
	indice_tema_atual -= 1
	if indice_tema_atual < 0:
		indice_tema_atual = temas.size() - 1
	_atualizar_exibicao_tema()

func _on_botao_fase_pressionado():
	var botao_fase = get_viewport().gui_get_focus_owner()
	if botao_fase and botao_fase is Button:
		var id_fase = botao_fase.name
		
		if dados_fases.has(id_fase):
			print("=== INICIANDO FASE ===")
			GameManager.id_fase_atual = id_fase
			get_tree().change_scene_to_file("res://scenes/challenges/ChallengeBase.tscn")
