# DragDropChallenge.gd
extends "res://scripts/challenges/ChallengeBase.gd"

@onready var background_texture_rect: TextureRect = %BackgroundTextureRect
@onready var drag_items_container: HBoxContainer = %DragItemsContainer # Contêiner para os itens arrastáveis
@onready var drop_areas_container: Control = %DropAreasContainer # Contêiner para as áreas de drop

var _items_to_drag: Array = []
var _drop_areas_data: Array = []
var _placed_correctly_count: int = 0
var _total_items_to_place: int = 0

func _ready():
	super._ready()
	# Conecte o signal de input global para capturar arrastar e  soltar
	set_process_input(true) # Habilita o _input para esta cena

# Métodos Sobrescritos da ChallengeBase

func _load_challenge_data() -> Dictionary:
	return _challenge_data

func _setup_ui_for_challenge(data: Dictionary) -> void:
	_items_to_drag = data.get("items_to_drag", [])
	_drop_areas_data = data.get("drop_areas", [])
	_total_items_to_place = _items_to_drag.size()
	_placed_correctly_count = 0
	
	if data.has("background_image_path"):
		background_texture_rect.texture = load(data["background_image_path"])
	
	# Limpa contêineres
	for child in drag_items_container.get_children(): child.queue_free()
	for child in drop_areas_container.get_children(): child.queue_free()
	
	# Cria itens arrastáveis
	for item_data in _items_to_drag:
		var drag_item = DraggableItem.new()
		drag_item.id = item_data.id
		drag_item.texture = load(item_data.image_path)
		drag_item.correct_drop_area_id = item_data.correct_drop_area_id
		drag_item.item_dropped.connect(_on_item_dropped) # Conecta o signal de drop
		drag_items_container.add_child(drag_item)
	
	# Cria áreas de drop
	for area_data in _drop_areas_data:
		var drop_area = DropZone.new() # Uma cena/script separada para a área de drop
		drop_area.id = area_data.id
		# Configurar posição e tamanho da área de drop (pode ser relativo à tela)
		# Exemplo: drop_area.position = Vector2(area_data.position_x * get_viewport_rect().size.x, ...)
		drop_area.position = Vector2(area_data.positon_x, area_data.position_y)
		drop_area.size = Vector2(area_data.size_x, area_data.size_y)
		# Visualizar temporariamente a área de drop usando um ColorRect
		var visualizer = ColorRect.new()
		visualizer.color = Color(1,1,1,0.2) # Transparente
		visualizer.size = drop_area.size
		drop_area.add_child(visualizer) 
		
		drop_areas_container.add_child(drop_area)
	
	update_progress_bar(_placed_correctly_count, _total_items_to_place)

func _start_challenge_logic() -> void:
	pass # A lógica principal é reativa ao drop

func _process_player_input(input_data) -> void:
	# Este método não é diretamente usado para o Drag & Drop principal
	# A interação acontece via sinais dos DraggableItem e DropZone
	pass

# Métodos Específicos do Drag & Drop

func _on_item_dropped(drag_item_id: String, dropped_on_area_id: String, is_correct: bool, drag_item_node: Node) -> void:
	if is_correct:
		_placed_correctly_count += 1
		_score += 20 # Exemplo de pontuação
		print("DragDrop: Item ", drag_item_id, " placed correctly on ", dropped_on_area_id)
		# Encontra a área de drop correta entre os filhos do container
		var drop_area_node: Control = null
		for area in drop_areas_container.get_children():
			if area.id == dropped_on_area_id:
				drop_area_node = area
				break

		# Se a área foi encontrada, reparenta o item para travar sua posição
		if drop_area_node:
			drag_item_node.get_parent().remove_child(drag_item_node)
			drop_area_node.add_child(drag_item_node)
			# Opcional: Centraliza o item dentro da área de drop
			drag_item_node.position = (drop_area_node.size / 2) - (drag_item_node.size / 2)
		drag_item_node.mouse_filter = Control.MOUSE_FILTER_IGNORE # Impede que seja arrastado novamente
		# Animação de sucesso
	else:
		_attempts += 1 # Contar tentativas totais
		_score = max(0, _score - 5) # Penalidade leve
		print("DragDrop: Item ", drag_item_id, " placed INCORRECTLY on ", dropped_on_area_id)
		# Animação de erro, item volta para o container original, etc.
		drag_item_node.return_to_original_position() # Método no DraggableItem
	
	update_progress_bar(_placed_correctly_count, _total_items_to_place)
	
	if _placed_correctly_count == _total_items_to_place:
		var is_sucess = _placed_correctly_count == _total_items_to_place
		_on_challenge_completed(is_sucess, _score, {"correct_placements": _placed_correctly_count, "total_placements": _total_items_to_place})

# Componentes auxiliares para Drag & Drop
# DraggableItem.gd (script anexado a um TextureRect ou Control)
# DropZone.gd (script anexado a um ColorRect ou Control)
# Precisa criar essas cenas/scripts separadamente
