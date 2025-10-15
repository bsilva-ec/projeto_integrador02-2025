# GameManager.gd
extends Node

const PlayerData = preload("res://scripts/player/Player.gd")
const CenaMenuPausa = preload("res://scenes/UI/PauseMenu.tscn")

var jogador_atual: PlayerData
var dados_progresso_jogo: Dictionary = {}

var id_fase_selecionada: String = ""
var container_desafio_atual: Node
var GerenciadorDadosDesafio: Node
var no_desafio_atual: Control

const CAMINHO_SALVAMENTO = "user://saves/"
const PREFIXO_ARQUIVO_ALUNO = "aluno_"
const EXTENSAO_ARQUIVO = ".json"

signal dados_aluno_carregados(dados_jogador)
signal dados_aluno_atualizados(dados_jogador)
signal fase_concluida(id_fase, pontuacao, sucesso)

var id_fase_atual: String
var desafios_fase_atual: Array
var indice_desafio: int = 0

func _ready():
	var diretorio = DirAccess.open(CAMINHO_SALVAMENTO)
	if not diretorio:
		DirAccess.make_dir_absolute(CAMINHO_SALVAMENTO)
	
	print("GameManager inicializado. Caminho de salvamento: ", ProjectSettings.globalize_path(CAMINHO_SALVAMENTO))
	
	GerenciadorDadosDesafio = get_node("/root/ChallengeDataManager")
	if not GerenciadorDadosDesafio:
		printerr("GameManager: ChallengeDataManager não encontrado!")

func carregar_perfil_aluno(nome_aluno: String) -> bool:
	jogador_atual = PlayerData.load(nome_aluno)
	if jogador_atual:
		dados_aluno_carregados.emit(jogador_atual)
		return true
	return false

func salvar_perfil_aluno_atual() -> bool:
	if jogador_atual == null:
		printerr("Nenhum aluno para salvar.")
		return false
	
	var nome_aluno = jogador_atual.student_name.to_lower().strip_edges()
	var caminho_arquivo = CAMINHO_SALVAMENTO + PREFIXO_ARQUIVO_ALUNO + nome_aluno + EXTENSAO_ARQUIVO
	var arquivo = FileAccess.open(caminho_arquivo, FileAccess.WRITE)
	
	if arquivo:
		var dados_serializados = {
			"id": jogador_atual.id,
			"name": jogador_atual.student_name,
			"total_score": jogador_atual.pontuacao_total,
			"progress": jogador_atual.progresso
		}
		var string_json = JSON.stringify(dados_serializados, "\t")
		arquivo.store_string(string_json)
		arquivo.close()
		print("Perfil de aluno salvo: ", nome_aluno)
		dados_aluno_atualizados.emit(jogador_atual)
		return true
	else:
		printerr("Falha ao salvar perfil de aluno: ", nome_aluno)
		return false

func criar_novo_perfil_aluno(nome_aluno: String) -> bool:
	if PlayerData.perfil_existe(nome_aluno):
		printerr("Perfil de aluno já existe: ", nome_aluno)
		return false
	
	jogador_atual = PlayerData.new(nome_aluno)
	var sucesso = jogador_atual.salvar()
	if sucesso:
		dados_aluno_carregados.emit(jogador_atual)
	return sucesso

func atualizar_progresso_fase(id_fase: String, pontuacao: int, sucesso: bool, tentativas: int, tempo_gasto: float, dados_adicionais: Dictionary = {}) -> void:
	if not jogador_atual:
		printerr("Nenhum aluno logado.")
		return
	
	var entrada_fase = jogador_atual.progresso.get(id_fase, {})
	entrada_fase["pontuacao"] = pontuacao
	entrada_fase["sucesso"] = sucesso
	entrada_fase["tentativas"] = tentativas
	entrada_fase["tempo_gasto"] = tempo_gasto
	entrada_fase["dados_adicionais"] = dados_adicionais
	
	jogador_atual.progresso[id_fase] = entrada_fase
	jogador_atual.pontuacao_total += pontuacao
	
	jogador_atual.salvar()
	dados_aluno_atualizados.emit(jogador_atual)

func fase_foi_concluida(id_fase: String) -> bool:
	if not jogador_atual: 
		return false
	return jogador_atual.progresso.has(id_fase) and jogador_atual.progresso[id_fase].get("sucesso", false)

func obter_progresso_fase(id_fase: String) -> Dictionary:
	return jogador_atual.progresso.get(id_fase, {}) if jogador_atual else {}

func obter_todos_alunos() -> Array:
	var lista_dados_alunos: Array = []
	var diretorio = DirAccess.open(CAMINHO_SALVAMENTO)
	
	if diretorio:
		diretorio.list_dir_begin()
		var nome_arquivo = diretorio.get_next()
		while nome_arquivo != "":
			if nome_arquivo.ends_with(EXTENSAO_ARQUIVO) and nome_arquivo.begins_with(PREFIXO_ARQUIVO_ALUNO):
				var nome_aluno_arquivo = nome_arquivo.replace(PREFIXO_ARQUIVO_ALUNO, "").replace(EXTENSAO_ARQUIVO, "")
				var caminho_arquivo = CAMINHO_SALVAMENTO + nome_arquivo
				var arquivo = FileAccess.open(caminho_arquivo, FileAccess.READ)
				if arquivo:
					var conteudo = arquivo.get_as_text()
					arquivo.close()
					var dados_json = JSON.parse_string(conteudo)
					if dados_json is Dictionary:
						lista_dados_alunos.append(dados_json)
			nome_arquivo = diretorio.get_next()
		diretorio.list_dir_end()
	
	return lista_dados_alunos

func iniciar_fase(id_fase: String, no_container: Node):
	print("=== GAMEMANAGER: INICIANDO FASE ===")
	print("ID Fase: ", id_fase)
	print("Container: ", no_container)
	
	id_fase_atual = id_fase
	desafios_fase_atual = GerenciadorDadosDesafio.get_challenges_for_phase(id_fase)
	
	print("Desafios carregados: ", desafios_fase_atual.size())
	for i in range(desafios_fase_atual.size()):
		print("Desafio ", i, ": ", desafios_fase_atual[i])
	
	desafios_fase_atual.shuffle()
	indice_desafio = 0
	container_desafio_atual = no_container
	
	print("Chamando _executar_proximo_desafio()...")
	_executar_proximo_desafio()

func _executar_proximo_desafio():
	print("=== GAMEMANAGER: _executar_proximo_desafio ===")
	print("Índice desafio: ", indice_desafio)
	
	if is_instance_valid(no_desafio_atual):
		print("Removendo desafio anterior...")
		no_desafio_atual.queue_free()
		no_desafio_atual = null
	
	if indice_desafio >= desafios_fase_atual.size():
		print("FASE CONCLUÍDA")
		_solicitar_saida_para_mapa()
		return
	
	var dados_desafio = desafios_fase_atual[indice_desafio]
	print("Dados do desafio: ", dados_desafio)
	
	var caminho_cena = ""
	match dados_desafio.get("type", "quiz"):
		"quiz": 
			caminho_cena = "res://scenes/challenges/QuizChallenge.tscn"
		"relate": 
			caminho_cena = "res://scenes/challenges/RelateChallenge.tscn"
		"dragdrop": 
			caminho_cena = "res://scenes/challenges/DragDropChallenge.tscn"
	
	print("Carregando: ", caminho_cena)
	
	if caminho_cena.is_empty():
		indice_desafio += 1
		_executar_proximo_desafio()
		return
	
	var cena_desafio = load(caminho_cena)
	if cena_desafio:
		if is_instance_valid(container_desafio_atual):
			for filho in container_desafio_atual.get_children():
				filho.queue_free()
			
			var instancia_desafio = cena_desafio.instantiate()
			no_desafio_atual = instancia_desafio
			container_desafio_atual.add_child(no_desafio_atual)
			
			instancia_desafio.desafio_concluido.connect(_on_desafio_concluido)
			instancia_desafio.pausa_solicitada.connect(_on_pausa_solicitada)
			
			print("Configurando desafio...")
			instancia_desafio.configurar_desafio(dados_desafio)
			indice_desafio += 1
	else:
		printerr("Cena não encontrada")
		indice_desafio += 1
		_executar_proximo_desafio()

func _on_desafio_concluido(id: String, pontuacao: int, sucesso: bool, dados_adicionais: Dictionary):
	print("Desafio ", id, " finalizado!")
	
	if jogador_atual:
		atualizar_progresso_fase(
			id_fase_atual,
			pontuacao,
			sucesso,
			no_desafio_atual._tentativas if no_desafio_atual else 0,
			no_desafio_atual._tempo_gasto if no_desafio_atual else 0.0,
			dados_adicionais
		)
	
	_executar_proximo_desafio()

func definir_id_fase_atual(novo_id_fase: String):
	print("GameManager: Definindo id_fase_atual para: ", novo_id_fase)
	id_fase_atual = novo_id_fase

func _on_pausa_solicitada():
	if get_tree().paused: 
		return
	
	get_tree().paused = true
	var menu_pausa = CenaMenuPausa.instantiate()
	get_tree().root.add_child(menu_pausa)
	menu_pausa.reiniciar_fase.connect(_on_menu_pausa_reiniciar_fase)
	menu_pausa.sair_para_mapa.connect(_on_menu_pausa_sair_para_mapa)

func _on_menu_pausa_reiniciar_fase():
	if is_instance_valid(no_desafio_atual):
		no_desafio_atual.queue_free()
	iniciar_fase(id_fase_selecionada, container_desafio_atual)

func _on_menu_pausa_sair_para_mapa():
	_solicitar_saida_para_mapa()

func _solicitar_saida_para_mapa():
	print("Saindo do desafio e voltando para o mapa...")
	get_tree().paused = false

	if is_instance_valid(no_desafio_atual):
		no_desafio_atual.queue_free()
		no_desafio_atual = null

	if desafios_fase_atual:
		desafios_fase_atual.clear()
	indice_desafio = 0

	get_tree().change_scene_to_file("res://scenes/UI/WorldMap.tscn")
