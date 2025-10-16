# ChallengeBase.gd
extends Control

# Sinais que todos os desafios vão emitir
signal desafio_concluido(sucesso: bool, pontuacao: int, dados: Dictionary)
signal desafio_iniciado()

# Variáveis comuns a todos os desafios
var dados_desafio: Dictionary = {}
var pontuacao: int = 0
var tempo_inicio: float = 0.0

# Referências aos nós da UI
@onready var mission_title_label: Label = find_child("MissionTitleLabel", true, false)
@onready var instructions_label: Label = find_child("InstructionsLabel", true, false)
@onready var progress_bar: ProgressBar = find_child("ProgressBar", true, false)
@onready var challenge_content_container: Control = find_child("ChallengeContentContainer", true, false)
@onready var menu_button: Button = find_child("MenuButton", true, false)

func _ready():
	print("CHALLENGE BASE - Carregado")
	configurar_ui_base()

func configurar_ui_base():
	print("Configurando UI base...")
	
	print("   - mission_title_label: ", mission_title_label != null)
	print("   - instructions_label: ", instructions_label != null)
	print("   - progress_bar: ", progress_bar != null)
	print("   - challenge_content_container: ", challenge_content_container != null)
	print("   - menu_button: ", menu_button != null)
	
	if menu_button:
		if not menu_button.pressed.is_connected(_on_menu_pressionado):
			menu_button.pressed.connect(_on_menu_pressionado)
		print("Botão menu conectado")

func iniciar_desafio(dados: Dictionary):
	print("ChallengeBase.iniciar_desafio()")
	
	dados_desafio = dados
	pontuacao = 0
	tempo_inicio = Time.get_ticks_msec()
	
	# Configurar UI com os dados do desafio
	if mission_title_label and dados.has("title"):
		mission_title_label.text = dados["title"]
		print("   - Título definido: ", dados["title"])
	
	if instructions_label and dados.has("instructions"):
		instructions_label.text = dados["instructions"]
		print("   - Instruções definidas")
	
	desafio_iniciado.emit()
	print("Desafio base configurado")

func finalizar_desafio(sucesso: bool, dados_extras: Dictionary = {}):
	var tempo_gasto = (Time.get_ticks_msec() - tempo_inicio) / 1000.0
	
	print("DESAFIO CONCLUÍDO:")
	print("   - Sucesso: ", sucesso)
	print("   - Pontuação: ", pontuacao)
	print("   - Tempo: ", tempo_gasto, "s")
	print("   - Dados: ", dados_extras)
	
	# Emitir sinal e mostrar recompensa
	desafio_concluido.emit(sucesso, pontuacao, dados_extras)
	mostrar_tela_recompensa(sucesso, pontuacao, dados_extras)

func mostrar_tela_recompensa(sucesso: bool, pontuacao: int, dados: Dictionary):
	print("Mostrando tela de recompensa...")
	
	# Atualizar pontuação do jogador
	if pontuacao > 0:
		GameManager.atualizar_pontuacao_jogador(pontuacao, dados)
	
	# Carregar e mostrar tela de recompensa
	var cena_recompensa = load("res://scenes/UI/RewardScreen.tscn")
	if cena_recompensa:
		var tela_recompensa = cena_recompensa.instantiate()
		get_tree().root.add_child(tela_recompensa)
		
		# Conectar ao sinal de fechamento - verifica sinais disponíveis
		if tela_recompensa.has_signal("fechado"):
			tela_recompensa.fechado.connect(_on_recompensa_fechada)
		elif tela_recompensa.has_signal("closed"):
			tela_recompensa.closed.connect(_on_recompensa_fechada)
		elif tela_recompensa.has_signal("continuar"):
			tela_recompensa.continuar.connect(_on_recompensa_fechada)
		else:
			# Se não encontrar sinal, usar fallback após tempo
			print("Nenhum sinal de fechamento encontrado, usando fallback")
			await get_tree().create_timer(3.0).timeout
			_on_recompensa_fechada()
		
		# Chamar função de mostrar resultado se existir
		if tela_recompensa.has_method("mostrar_resultado"):
			tela_recompensa.mostrar_resultado(sucesso, pontuacao, dados)
		elif tela_recompensa.has_method("show_result"):
			tela_recompensa.show_result(sucesso, pontuacao, dados)
		else:
			print("Método mostrar_resultado não encontrado na RewardScreen")
	else:
		printerr("RewardScreen não encontrada!")
		# Se não tiver tela de recompensa, vai direto para o mapa
		voltar_para_mapa()

func _on_recompensa_fechada():
	print("Tela de recompensa fechada, voltando para mapa...")
	voltar_para_mapa()

func voltar_para_mapa():
	print("Voltando para WorldMap...")
	
	# Pequeno delay para garantir que tudo foi processado
	await get_tree().process_frame
	
	# Verificar se tem mais desafios na fase atual
	if SceneManager and SceneManager.tem_mais_desafios():
		print("Próximo desafio disponível")
		SceneManager.avancar_para_proximo_desafio()
	else:
		print("Fase completa! Limpando dados")
		if SceneManager:
			SceneManager.limpar_dados()
	
	# Voltar para o mapa
	get_tree().change_scene_to_file("res://scenes/UI/WorldMap.tscn")

func atualizar_progresso(atual: int, total: int):
	if progress_bar:
		var percentual = float(atual) / total * 100
		progress_bar.value = percentual

func _on_menu_pressionado():
	print("Botão Menu pressionado - Abrindo pause")
	abrir_menu_pause()

func abrir_menu_pause():
	# Carregar menu de pause
	var cena_pause = load("res://scenes/UI/PauseMenu.tscn")
	if cena_pause:
		var menu_pause = cena_pause.instantiate()
		get_tree().root.add_child(menu_pause)
		
		# Conectar sinais do menu de pause
		if menu_pause.has_signal("retomado"):
			menu_pause.retomado.connect(_on_pause_retomado)
		if menu_pause.has_signal("reiniciar_desafio"):
			menu_pause.reiniciar_desafio.connect(_on_pause_reiniciar)
		if menu_pause.has_signal("sair_para_mapa"):
			menu_pause.sair_para_mapa.connect(_on_pause_sair)
		
		# Pausar o jogo
		get_tree().paused = true
		print("Jogo pausado")
	else:
		printerr("Menu de pause não encontrado!")
		# Fallback: voltar para mapa
		voltar_para_mapa()

func _on_pause_retomado():
	print("Retomando do pause...")
	get_tree().paused = false

func _on_pause_reiniciar():
	print("Reiniciando desafio do pause...")
	get_tree().paused = false
	# Recarregar a cena atual
	get_tree().reload_current_scene()

func _on_pause_sair():
	print("Saindo para mapa do pause...")
	get_tree().paused = false
	if SceneManager:
		SceneManager.limpar_dados()
	get_tree().change_scene_to_file("res://scenes/UI/WorldMap.tscn")
