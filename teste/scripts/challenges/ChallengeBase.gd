# ChallengeBase.gd
extends Control

@export var id_desafio: String = ""
var label_titulo_missao: Label
var label_instrucoes: Label
var barra_progresso: ProgressBar
var container_conteudo_desafio: Control
var botao_menu: Button

signal desafio_iniciado(id)
signal desafio_concluido(id, pontuacao, sucesso, dados_adicionais)
signal pausa_solicitada

var _dados_desafio: Dictionary = {}
var _pontuacao: int = 0
var _tentativas: int = 0
var _tempo_gasto: float = 0.0
var _tempo_inicio: float = 0.0

var inicializado: bool = false

func _ready():
	print("=== CHALLENGEBASE: Container carregado ===")
	
	if inicializado:
		return
		
	inicializado = true
	_buscar_nos_interface()
	print("🔍 ChallengeBase - Visibilidade:")
	print("   - label_titulo_missao: ", label_titulo_missao != null, " - visível: ", label_titulo_missao.visible if label_titulo_missao else false)
	print("   - label_instrucoes: ", label_instrucoes != null, " - visível: ", label_instrucoes.visible if label_instrucoes else false)
	print("   - container_conteudo_desafio: ", container_conteudo_desafio != null, " - visível: ", container_conteudo_desafio.visible if container_conteudo_desafio else false)
	print("   - self (ChallengeBase): ", self.visible)
	await get_tree().process_frame
	_iniciar_desafios()

func _iniciar_desafios():
	print("Iniciando desafios para: ", GameManager.id_fase_atual)
	
	if GameManager.id_fase_atual:
		GameManager.iniciar_fase(GameManager.id_fase_atual, self)
	else:
		printerr("Nenhuma fase definida!")

func _buscar_nos_interface():
	label_titulo_missao = find_child("MissionTitleLabel", true, false)
	label_instrucoes = find_child("InstructionsLabel", true, false)
	barra_progresso = find_child("ProgressBar", true, false)
	container_conteudo_desafio = find_child("ChallengeContentContainer", true, false)
	botao_menu = find_child("MenuButton", true, false)
	
	if botao_menu:
		print("MenuButton encontrado")
		botao_menu.pressed.connect(_on_botao_menu_pressionado)
	else:
		printerr("MenuButton não encontrado")

func _carregar_dados_desafio() -> Dictionary:
	printerr("ChallengeBase: _carregar_dados_desafio() deve ser implementado pelas classes derivadas.")
	return {}

func _configurar_interface_desafio(_dados: Dictionary) -> void:
	printerr("ChallengeBase: _configurar_interface_desafio() deve ser implementado pelas classes derivadas.")

func _iniciar_logica_desafio() -> void:
	printerr("ChallengeBase: _iniciar_logica_desafio() deve ser implementado pelas classes derivadas.")

func _processar_entrada_jogador(_dados_entrada) -> void:
	printerr("ChallengeBase: _processar_entrada_jogador() deve ser implementado pelas classes derivadas.")

func configurar_desafio(dados: Dictionary) -> void:
	_dados_desafio = dados
	_pontuacao = 0
	_tentativas = 0
	_tempo_gasto = 0.0
	
	if _dados_desafio.is_empty():
		printerr("ChallengeBase: Recebeu dados vazios!")
		pausa_solicitada.emit()
		return
	
	id_desafio = _dados_desafio.get("id", "id_desconhecido")
	
	label_titulo_missao.text = _dados_desafio.get("title", "Desafio")
	label_instrucoes.text = _dados_desafio.get("instructions", "Complete a missão.")
	
	_carregar_dados_desafio()
	_configurar_interface_desafio(_dados_desafio)
	_tempo_inicio = Time.get_ticks_msec()
	desafio_iniciado.emit(_dados_desafio.get("id", "id_desconhecido"))
	_iniciar_logica_desafio()

func _on_desafio_concluido(sucesso: bool, pontuacao_final: int, info_adicional: Dictionary = {}) -> void:
	_tempo_gasto = (Time.get_ticks_msec() - _tempo_inicio) / 1000.0
	
	desafio_concluido.emit(id_desafio, pontuacao_final, sucesso, info_adicional)
	pausa_solicitada.emit()

func atualizar_barra_progresso(atual: int, total: int) -> void:
	if barra_progresso:
		barra_progresso.value = float(atual) / total * 100

func _on_botao_menu_pressionado() -> void:
	print("Botão menu pressionado do desafio.")
	pausa_solicitada.emit()
