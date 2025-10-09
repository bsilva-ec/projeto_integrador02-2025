# RelateChallenge.gd
extends "res://scripts/challenges/ChallengeBase.gd"

const RelateItem = preload("res://scripts/components/RelateItem.gd")

@onready var left_column_container: VBoxContainer = %LeftColumnContainer # Contêiner para itens da coluna esquerda
@onready var right_column_container: VBoxContainer = %RightColumnContêiner # Contêiner para itens da coluna direita
@onready var drawing_canvas: Control = %DrawingConvas # Um Control onde as linhas serão desenhadas

var _items_left: Array = []
var _items_right: Array = []
var _correct_connections_data: Array = []
var _current_connections: Dictionary = {} # {left_item_id: right_item_id}
var _correct_connections_count: int = 0
var _total_connections_needed: int = 0

var _is_drawing_line: bool = false
var _drawing_start_pos: Vector2
var _current_drawing_line_item_id: String

func _ready():
	super._ready()
	drawing_canvas.set_process_input(true)
	drawing_canvas.gui_input.connect(_on_canvas_gui_input)

# Método Sobrescritos da ChallengeBase

func _load_challenge_data() -> Dictionary:
	return _challenge_data

func _setup_ui_for_challenge(data: Dictionary) -> void:
	_items_left = data.get("items_left_column", [])
	_items_right = data.get("items_right_column", [])
	_correct_connections_data = data.get("correct_connections", [])
	_total_connections_needed = _correct_connections_data.size()
	_correct_connections_count = 0
	_current_connections.clear()
	
	# Limpa contêineres
	for item_data in _items_left:
		var item_node = RelateItem.new() # Componente para cada item
		item_node.id = item_data.id
		item_node.set_text(item_data.text)
		item_node.set_image(load(item_data.image_path))
		left_column_container.add_child(item_node)
	
	for item_data in _items_right:
		var item_node = RelateItem.new()
		item_node.id = item_data.id
		item_node.set_text(item_data.text)
		item_node.set_image(load(item_data.image_path))
		right_column_container.add_child(item_node)
	
	update_progress_bar(_correct_connections_count, _total_connections_needed)
	drawing_canvas.queue_redraw() # Garante que as linhas iniciais (se houver) sejam desenhadas

func _start_challenge_logic() -> void:
	pass # Lógica é reativa à interação

func _process_player_input(input_data) -> void:
	# O _input será gerenciado pelo gui_input do drawing_canvas
	pass

# Métodos Específicos do Relacionar

func _on_canvas_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed: # Mouse clicado
				var item_under_mouse = _get_relate_item_at_position(event.position)
				if item_under_mouse:
					_is_drawing_line = true
					_drawing_start_pos = item_under_mouse.global_position + item_under_mouse.size / 2
					_current_drawing_line_item_id = item_under_mouse.id
					drawing_canvas.queue_redraw() # Começa a desenhar a linha
				else: # Mouse solto
					if _is_drawing_line:
						_is_drawing_line = false
						var target_item = _get_relate_item_at_position(event.position)
						if target_item and target_item.id != _current_drawing_line_item_id: # Não pode ligar a si mesmo
							_try_connect(_current_drawing_line_item_id, target_item.id)
						drawing_canvas.queue_redraw() # Para de desenhar a linha "solta"
	
	elif event is InputEventMouseMotion:
		if _is_drawing_line:
			drawing_canvas.queue_redraw() # Redesenha a linha enquanto o mouse se move

func _get_relate_item_at_position(canvas_pos: Vector2) -> Node:
	# Helper para encontrar qual item RelateItem está sob o mouse
	# Precisa de uma maneira de iterar sobre todos os itens de ambas as colunas
	# e verificar se o canvas_pos está dentro do retângulo de algum item
	# Pode ser complexo, simplificando para exemplo:
	for child in left_column_container.get_children():
		if child is RelateItem and child.get_global_rect().has_point(canvas_pos):
			return child
	for child in right_column_container.get_children():
		if child is RelateItem and child.get_global_rect().has_point(canvas_pos):
			return child
	return null

func _try_connect(source_id: String, target_id: String) -> void:
	var is_correct = false
	var connection_key = ""
	
	# Verifica se a conexão é válida (fonte da esquerda, alvo da direita ou vice-versa)
	var is_source_left = _items_left.any(func(item): return item.id == source_id)
	var is_target_right = _items_right.any(func(item): return item.id == target_id)
	
	if is_source_left and is_target_right:
		connection_key = source_id + "-" + target_id
		for conn in _correct_connections_data:
			if conn.left_id == source_id and conn.right_id == target_id:
				is_correct = true
				break
	elif not is_source_left and not is_target_right: # Ambos são da mesma coluna, ou inválidos
		pass # Não permitir conexão entre itens da mesma coluna
	else: # Conexão inválida (ex: target está na coluna esquerda)
		pass
	
	if is_correct:
		if not _current_connections.has(source_id) and not _current_connections.has(target_id): # Apenas uma conexão por item
			_current_connections[source_id] = target_id
			_current_connections[target_id] = source_id # Para verificar se o item já está conectado
			_correct_connections_count += 1
			_score += 30 # Exemplo de pontuação
			print("Relate: Correct connection between ", source_id, " and ", target_id)
			# Animação de sucesso, a linha fica permanente e verde
		else: 
			print("Relate: One of the items is already connected.")
			# Feedback visual de que a conexão não foi aceita
	else:
		_attempts += 1
		_score = max(0, _score - 5) # Penalidade leve
		print("Relate: Incorrect connection between ", source_id, " and ", target_id)
		# Animação de erro, a linha "some" ou fica vermelha e depois some
	
	update_progress_bar(_correct_connections_count, _total_connections_needed)
	drawing_canvas.queue_redraw() # Redesenha todas as linhas fixas
	
	if _correct_connections_count == _total_connections_needed:
		_finish_relate_challenge()

func _finish_relate_challenge() -> void:
	var is_success = _correct_connections_count == _total_connections_needed
	_on_challenge_completed(is_success, _score, {"correct_connections": _correct_connections_count, "total_connections": _total_connections_needed})

func _draw():
	# Desenha as linha permanentementes
	for left_id in _current_connections:
		var right_id = _current_connections[left_id]
		var left_item = _get_relate_item_node_by_id(left_id) # Vai precisar implementar isso
		var right_item = _get_relate_item_node_by_id(right_id) # Vai pprecisar implementar isso
		
		if left_item and right_item: 
			var start_point = left_item.global_position + left_item.size / 2
			var end_point = right_item.global_position + right_item.size / 2
			drawing_canvas.draw_line(drawing_canvas.to_local(start_point), drawing_canvas.to_local(end_point), Color.GREEN, 5)
	
	# Desenha a linha temporária enquanto o jogador está arrastando
	if _is_drawing_line:
		drawing_canvas.draw_line(drawing_canvas.to_local(_drawing_start_pos), drawing_canvas.to_local(get_viewport().get_mouse_position()), Color.BLUE, 3)	

func _get_relate_item_node_by_id(id: String) -> Node:
	# Implementar este método para encontrar o nó de RelateItem pelo seu ID
	# Isso pode envolver iterar sobre os filhos dos contêineres de colunas.
	# Exemplo simples:
	for child in left_column_container.get_children():
		if child is RelateItem and child.id == id:
			return child
	for child in right_column_container.get_children():
		if child is RelateItem and child.id == id:
			return child
	return null
