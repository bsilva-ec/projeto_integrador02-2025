# FlowManager.gd
extends Node

const CAMINHO_MENU_PRINCIPAL = "res://scenes/UI/MainMenu.tscn"
const CAMINHO_MAPA_MUNDIAL = "res://scenes/UI/WorldMap.tscn"
const CAMINHO_TELA_RECOMPENSA = "res://scenes/UI/RewardScreen.tscn"

var caminhos_cenas_fases: Dictionary = {}

signal transicao_cena_iniciada(caminho_cena)
signal transicao_cena_finalizada(caminho_cena)

func mudar_cena(caminho_cena: String) -> void:
	if not ResourceLoader.exists(caminho_cena, "PackedScene"):
		printerr("FlowManager: Caminho de cena não existe: ", caminho_cena)
		return
	
	transicao_cena_iniciada.emit(caminho_cena)
	print("FlowManager: Mudando para cena: ", caminho_cena)
	
	var cena_atual = get_tree().current_scene
	if cena_atual:
		cena_atual.queue_free()
	
	var proxima_cena_empacotada = load(caminho_cena)
	var proxima_cena = proxima_cena_empacotada.instantiate()
	get_tree().root.add_child(proxima_cena)
	get_tree().current_scene = proxima_cena
	
	transicao_cena_finalizada.emit(caminho_cena)

func ir_para_menu_principal() -> void:
	mudar_cena(CAMINHO_MENU_PRINCIPAL)

func ir_para_mapa_mundial() -> void:
	mudar_cena(CAMINHO_MAPA_MUNDIAL)

func ir_para_fase(id_fase: String) -> void:
	if caminhos_cenas_fases.has(id_fase):
		mudar_cena(caminhos_cenas_fases[id_fase])
	else:
		printerr("FlowManager: ID de fase não encontrado: ", id_fase)

func ir_para_tela_recompensa(sucesso: bool, pontuacao: int, dados_adicionais: Dictionary = {}):
	var cena_recompensa = load(CAMINHO_TELA_RECOMPENSA)
	if cena_recompensa:
		var instancia_recompensa = cena_recompensa.instantiate()
		
		# Adicionar sobre a cena atual (não substituir)
		get_tree().current_scene.add_child(instancia_recompensa)
		
		# Configurar a tela de recompensa
		instancia_recompensa.configurar(sucesso, pontuacao, dados_adicionais)
	else:
		printerr("Tela de recompensa não encontrada!")
