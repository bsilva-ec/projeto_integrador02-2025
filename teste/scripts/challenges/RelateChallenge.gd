# RelateChallenge.gd
extends "res://scripts/challenges/ChallengeBase.gd"

const ItemRelacionar = preload("res://scripts/components/RelateItem.gd")

var container_coluna_esquerda: VBoxContainer
var container_coluna_direita: VBoxContainer
var canvas_desenho: Control

var _itens_esquerda: Array = []
var _itens_direita: Array = []
var _conexoes_corretas: Array = []
var _conexoes_atuais: Dictionary = {}
var _contador_conexoes_corretas: int = 0
var _total_conexoes_necessarias: int = 0

var _desenhando_linha: bool = false
var _posicao_inicio_desenho: Vector2
var _id_item_linha_atual: String

func _ready():
	super._ready()
	container_coluna_esquerda = find_child("LeftColumnContainer", true, false)
	container_coluna_direita = find_child("RightColumnContainer", true, false) 
	canvas_desenho = find_child("DrawingCanvas", true, false)
	
	if canvas_desenho:
		canvas_desenho.set_process_input(true)
		canvas_desenho.gui_input.connect(_on_canvas_entrada_interface)

func _carregar_dados_desafio() -> Dictionary:
	return _dados_desafio

func _configurar_interface_desafio(dados: Dictionary) -> void:
	_itens_esquerda = dados.get("items_left_column", [])
	_itens_direita = dados.get("items_right_column", [])
	_conexoes_corretas = dados.get("correct_connections", [])
	_total_conexoes_necessarias = _conexoes_corretas.size()
	_contador_conexoes_corretas = 0
	_conexoes_atuais.clear()
	
	for item_dados in _itens_esquerda:
		var no_item = ItemRelacionar.new()
		no_item.id = item_dados.id
		no_item.definir_texto(item_dados.text)
		no_item.definir_imagem(load(item_dados.image_path))
		container_coluna_esquerda.add_child(no_item)
	
	for item_dados in _itens_direita:
		var no_item = ItemRelacionar.new()
		no_item.id = item_dados.id
		no_item.definir_texto(item_dados.text)
		no_item.definir_imagem(load(item_dados.image_path))
		container_coluna_direita.add_child(no_item)
	
	atualizar_barra_progresso(_contador_conexoes_corretas, _total_conexoes_necessarias)
	canvas_desenho.queue_redraw()

func _iniciar_logica_desafio() -> void:
	pass

func _processar_entrada_jogador(_dados_entrada) -> void:
	pass

func _on_canvas_entrada_interface(evento: InputEvent):
	if evento is InputEventMouseButton:
		if evento.button_index == MOUSE_BUTTON_LEFT:
			if evento.pressed:
				var item_sob_mouse = _obter_item_relacionar_na_posicao(evento.position)
				if item_sob_mouse:
					_desenhando_linha = true
					_posicao_inicio_desenho = item_sob_mouse.global_position + item_sob_mouse.size / 2
					_id_item_linha_atual = item_sob_mouse.id
					canvas_desenho.queue_redraw()
				else:
					if _desenhando_linha:
						_desenhando_linha = false
						var item_alvo = _obter_item_relacionar_na_posicao(evento.position)
						if item_alvo and item_alvo.id != _id_item_linha_atual:
							_tentar_conectar(_id_item_linha_atual, item_alvo.id)
						canvas_desenho.queue_redraw()
	
	elif evento is InputEventMouseMotion:
		if _desenhando_linha:
			canvas_desenho.queue_redraw()

func _obter_item_relacionar_na_posicao(posicao_canvas: Vector2) -> Node:
	var posicao_mouse_global = canvas_desenho.to_global(posicao_canvas)
	
	for filho in container_coluna_esquerda.get_children():
		if filho is ItemRelacionar and filho.get_global_rect().has_point(posicao_mouse_global):
			return filho
	for filho in container_coluna_direita.get_children():
		if filho is ItemRelacionar and filho.get_global_rect().has_point(posicao_mouse_global):
			return filho
	return null

func _tentar_conectar(id_origem: String, id_alvo: String) -> void:
	var correto = false
	
	# CORREÇÃO: substituir any() por loop tradicional
	var origem_esquerda = false
	for item in _itens_esquerda:
		if item.id == id_origem:
			origem_esquerda = true
			break
	
	var alvo_direita = false  
	for item in _itens_direita:
		if item.id == id_alvo:
			alvo_direita = true
			break
	
	if correto:
		if not _conexoes_atuais.has(id_origem) and not _conexoes_atuais.has(id_alvo):
			_conexoes_atuais[id_origem] = id_alvo
			_conexoes_atuais[id_alvo] = id_origem
			_contador_conexoes_corretas += 1
			_pontuacao += 30
			print("Relate: Conexão correta entre ", id_origem, " e ", id_alvo)
		else: 
			print("Relate: Um dos itens já está conectado.")
	else:
		_tentativas += 1
		_pontuacao = max(0, _pontuacao - 5)
		print("Relate: Conexão incorreta entre ", id_origem, " e ", id_alvo)
	
	atualizar_barra_progresso(_contador_conexoes_corretas, _total_conexoes_necessarias)
	canvas_desenho.queue_redraw()
	
	if _contador_conexoes_corretas == _total_conexoes_necessarias:
		_finalizar_desafio_relacionar()

func _finalizar_desafio_relacionar() -> void:
	var sucesso = _contador_conexoes_corretas == _total_conexoes_necessarias
	_on_desafio_concluido(sucesso, _pontuacao, {
		"conexoes_corretas": _contador_conexoes_corretas, 
		"total_conexoes": _total_conexoes_necessarias
	})

func _draw():
	for id_esquerda in _conexoes_atuais:
		var id_direita = _conexoes_atuais[id_esquerda]
		var item_esquerda = _obter_no_item_por_id(id_esquerda)
		var item_direita = _obter_no_item_por_id(id_direita)
		
		if item_esquerda and item_direita: 
			var ponto_inicio = item_esquerda.global_position + item_esquerda.size / 2
			var ponto_fim = item_direita.global_position + item_direita.size / 2
			canvas_desenho.draw_line(
				canvas_desenho.to_local(ponto_inicio), 
				canvas_desenho.to_local(ponto_fim), 
				Color.GREEN, 5
			)
	
	if _desenhando_linha:
		canvas_desenho.draw_line(
			canvas_desenho.to_local(_posicao_inicio_desenho), 
			canvas_desenho.to_local(get_viewport().get_mouse_position()), 
			Color.BLUE, 3
		)

func _obter_no_item_por_id(id: String) -> Node:
	for filho in container_coluna_esquerda.get_children():
		if filho is ItemRelacionar and filho.id == id:
			return filho
	for filho in container_coluna_direita.get_children():
		if filho is ItemRelacionar and filho.id == id:
			return filho
	return null
