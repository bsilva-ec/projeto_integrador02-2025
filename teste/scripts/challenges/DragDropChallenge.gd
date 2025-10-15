# DragDropChallenge.gd
extends "res://scripts/challenges/ChallengeBase.gd"

var textura_fundo: TextureRect
var container_itens_arrastaveis: HBoxContainer
var container_areas_soltura: Control

var _itens_para_arrastar: Array = []
var _dados_areas_soltura: Array = []
var _contador_colocacoes_corretas: int = 0
var _total_itens_para_colocar: int = 0

func _ready():
	super._ready()
	textura_fundo = find_child("BackgroundTextureRect", true, false)
	container_itens_arrastaveis = find_child("DragItemsContainer", true, false)
	container_areas_soltura = find_child("DropAreasContainer", true, false)
	set_process_input(true)

func _carregar_dados_desafio() -> Dictionary:
	return _dados_desafio

func _configurar_interface_desafio(dados: Dictionary) -> void:
	_itens_para_arrastar = dados.get("items_to_drag", [])
	_dados_areas_soltura = dados.get("drop_areas", [])
	_total_itens_para_colocar = _itens_para_arrastar.size()
	_contador_colocacoes_corretas = 0
	
	# Carregar background
	if dados.has("background_image_path"):
		var textura_fundo_carregada = load(dados["background_image_path"])
		if textura_fundo_carregada:
			textura_fundo.texture = textura_fundo_carregada
	
	# Limpar contêineres
	for filho in container_itens_arrastaveis.get_children(): 
		filho.queue_free()
	for filho in container_areas_soltura.get_children(): 
		filho.queue_free()
	
	# Criar itens arrastáveis
	for dados_item in _itens_para_arrastar:
		var item_arrastavel = DraggableItem.new()
		item_arrastavel.id = dados_item.id
		item_arrastavel.id_area_soltura_correta = dados_item.correct_drop_area_id
		
		# Configurar visual do item
		item_arrastavel.custom_minimum_size = Vector2(80, 80)
		item_arrastavel.size = Vector2(80, 80)
		
		# Adicionar TextureRect como filho para a imagem
		var textura_item = TextureRect.new()
		textura_item.texture = load(dados_item.image_path)
		textura_item.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		textura_item.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		textura_item.size = Vector2(70, 70)
		textura_item.position = Vector2(5, 5)
		item_arrastavel.add_child(textura_item)
		
		item_arrastavel.item_soltado.connect(_on_item_soltado)
		container_itens_arrastaveis.add_child(item_arrastavel)
	
	# Criar áreas de soltura
	for dados_area in _dados_areas_soltura:
		var zona_soltura = preload("res://scenes/components/DropZone.tscn").instantiate()
		zona_soltura.id = dados_area.id
		zona_soltura.position = Vector2(dados_area.position_x, dados_area.position_y)
		zona_soltura.tamanho_padrao = Vector2(dados_area.size_x, dados_area.size_y)
		
		# Opcional: adicionar label para identificar
		var label = Label.new()
		label.text = dados_area.id
		label.position = Vector2(5, 5)
		zona_soltura.add_child(label)
		
		container_areas_soltura.add_child(zona_soltura)
	
	atualizar_barra_progresso(_contador_colocacoes_corretas, _total_itens_para_colocar)

func _iniciar_logica_desafio() -> void:
	pass

func _processar_entrada_jogador(_dados_entrada) -> void:
	pass

func _on_item_soltado(id_item_arrastavel: String, id_area_soltada: String, correto: bool, no_item_arrastavel: Node) -> void:
	if correto:
		_contador_colocacoes_corretas += 1
		_pontuacao += 20
		print("DragDrop: Item ", id_item_arrastavel, " colocado corretamente em ", id_area_soltada)
		
		var no_area_soltura: Control = null
		for area in container_areas_soltura.get_children():
			if area.id == id_area_soltada:
				no_area_soltura = area
				break

		if no_area_soltura:
			no_item_arrastavel.get_parent().remove_child(no_item_arrastavel)
			no_area_soltura.add_child(no_item_arrastavel)
			no_item_arrastavel.position = (no_area_soltura.size / 2) - (no_item_arrastavel.size / 2)
		no_item_arrastavel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	else:
		_tentativas += 1
		_pontuacao = max(0, _pontuacao - 5)
		print("DragDrop: Item ", id_item_arrastavel, " colocado INCORRETAMENTE em ", id_area_soltada)
		no_item_arrastavel.retornar_para_posicao_original()
	
	atualizar_barra_progresso(_contador_colocacoes_corretas, _total_itens_para_colocar)
	
	if _contador_colocacoes_corretas == _total_itens_para_colocar:
		var sucesso = _contador_colocacoes_corretas == _total_itens_para_colocar
		_on_desafio_concluido(sucesso, _pontuacao, {
			"colocacoes_corretas": _contador_colocacoes_corretas, 
			"total_colocacoes": _total_itens_para_colocar
		})
