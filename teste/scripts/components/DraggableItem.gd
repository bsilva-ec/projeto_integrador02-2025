# DraggableItem.gd
extends TextureRect

@export var id: String = ""
@export var correct_drop_area_id: String = "" # ID da área de drop correta
@export var drag_speed: float = 2000.0 # Velocidade de retorno, se for o caso

signal item_dropped(drag_item_id, dropped_on_area_id, is_correct, drag_item_node)

@onready var drag_area: Area2D = $DragArea # Referência ao Area2D filho

var _is_dragging: bool = false
var _drag_offset: Vector2 # Diferença entre o clique e o canto do item
var _original_parent: Node
var _original_position_in_parent: Vector2
var _is_locked: bool = false # Nova flag para controlar se o item pode ser arrastado

func _ready():
	# Cache a posição original e o pai
	_original_parent = get_parent()
	_original_position_in_parent = position

	# Habilita a detecção de input para arrastar
	mouse_filter = Control.MOUSE_FILTER_STOP # Captura eventos de mouse
	# Permite detectar arrasto via _input
	set_process_input(true)

func _input(event: InputEvent):
	if _is_locked: return # Se o item está travado (já colocado corretamente), ignora input
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and get_rect().has_point(get_local_mouse_position()):
			_is_dragging = true
			_drag_offset = event.position - global_position
			
			# Traz o item para a frente (topo da árvore de nós) para que não seja escondido por outros itens
			get_parent().remove_child(self)
			get_tree().root.add_child(self)
			
			# Ajusta a posição para o mouse
			global_position = event.position - _drag_offset
			
		elif not event.pressed and _is_dragging:
			_is_dragging = false
			_check_drop_location()
		
	if event is InputEventMouseMotion and _is_dragging:
		global_position = event.position - _drag_offset

func _check_drop_location():
	var dropped_on_area_id = ""
	var is_correct_placement = false
	var drop_zone_node: DropZone = null
	
	# Usa o Area2D para verificar sobreposição com DropZones
	for area in drag_area.get_overlapping_areas():
		if area.get_parent() is DropZone: # Verifica se a área de colisão pertence a um DropZone
			drop_zone_node = area.get_parent() as DropZone
			dropped_on_area_id = drop_zone_node.id
			break # Encontrou a primeira DropZone, pode ser suficiente
	
	if dropped_on_area_id:
		is_correct_placement = (dropped_on_area_id == correct_drop_area_id)
		print("Dropped on: ", dropped_on_area_id, " correct: ", is_correct_placement)
		item_dropped.emit(id, dropped_on_area_id, is_correct_placement, self)

		if is_correct_placement:
			# Posiciona o item no centro da DropZone
			if drop_zone_node:
				# Transforma a posição global da DropZone para a posição local do PARENT do DraggableItem
				# Antes de reposicionar o DraggableItem para seu pai original
				var target_pos_global = drop_zone_node.global_position + drop_zone_node.size / 2
				var new_pos_in_root = target_pos_global - size / 2
				global_position = new_pos_in_root
				
				# O item permanece na cena raiz por enquanto, mas está visualmente sobre a DropZone
				_is_locked = true # Trava o item no lugar
			else: # Fallback se drop_zone_node for null por algum motivo
				return_to_original_position()
		else:
			return_to_original_position()
	else:
		# Não soltou em nenhuma área válida, volta para a posição original
		print("Dropped outside any valid drop zone.")
		item_dropped.emit(id, "", false, self) # Sinaliza que não foi em área válida
		return_to_original_position()

func return_to_original_position():
	# Remover da cena raiz
	get_tree().root.remove_child(self)
	# Adicionar de volta ao pai original na posição original
	_original_parent.add_child(self)
	position = _original_position_in_parent
	# Pode adicionar uma animação aqui (Tween)

# Método para travar o item no lugar (útil se o DragDropChallenge quiser fazer isso)
func lock_in_place(target_global_position: Vector2):
	get_tree().root.remove_child(self)
	_original_parent.add_child(self) # Adiciona de volta ao pai original para manter a hierarquia

	# Calcular a posição local dentro do PARENT ORIGINAL
	position = _original_parent.to_local(target_global_position - size / 2)

	_is_locked = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
