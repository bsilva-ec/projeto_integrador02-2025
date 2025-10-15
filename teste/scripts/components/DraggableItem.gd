# DraggableItem.gd
extends Control

@export var id: String = ""
@export var id_area_soltura_correta: String = ""
@export var velocidade_arrasto: float = 2000.0

signal item_soltado(id_item_arrastavel, id_area_soltada, correto, no_item_arrastavel)

# Já não precisa mais da Area2D separada
var _arrastando: bool = false
var _offset_arrasto: Vector2
var _pai_original: Node
var _posicao_original_no_pai: Vector2
var _travado: bool = false

func _ready():
	_pai_original = get_parent()
	_posicao_original_no_pai = position
	
	# Configurar para ser arrastável
	mouse_filter = Control.MOUSE_FILTER_PASS

func _gui_input(evento):
	if _travado: 
		return
	
	if evento is InputEventMouseButton and evento.button_index == MOUSE_BUTTON_LEFT:
		if evento.pressed:
			# Iniciar arrasto
			_arrastando = true
			_offset_arrasto = get_global_mouse_position() - global_position
			# Mover para a raiz para ficar acima de tudo
			get_parent().remove_child(self)
			get_tree().root.add_child(self)
			z_index = 1000  # Garantir que fique por cima
		elif not evento.pressed and _arrastando:
			# Finalizar arrasto
			_arrastando = false
			_verificar_local_soltura()
		
	if evento is InputEventMouseMotion and _arrastando:
		# Atualizar posição durante o arrasto
		global_position = get_global_mouse_position() - _offset_arrasto

func _verificar_local_soltura():
	var posicao_soltura = get_global_mouse_position()
	var id_area_soltada = ""
	var colocacao_correta = false
	var zona_soltura_encontrada: DropZone = null
	
	# Buscar todas as zonas de soltura na cena
	var zonas_soltura = _buscar_todas_zonas_soltura()
	
	for zona in zonas_soltura:
		if zona.ponto_esta_dentro(posicao_soltura):
			zona_soltura_encontrada = zona
			id_area_soltada = zona.id
			break
	
	if id_area_soltada:
		colocacao_correta = (id_area_soltada == id_area_soltura_correta)
		
		item_soltado.emit(id, id_area_soltada, colocacao_correta, self)
		
		if colocacao_correta:
			travar_em_posicao(zona_soltura_encontrada.global_position)
		else:
			retornar_para_posicao_original()
	else:
		# Soltou em lugar nenhum
		item_soltado.emit(id, "", false, self)
		retornar_para_posicao_original()

func _buscar_todas_zonas_soltura() -> Array:
	var zonas: Array = []
	
	# Buscar recursivamente por DropZones na cena atual
	_buscar_zonas_recursivamente(get_tree().current_scene, zonas)
	
	return zonas

func _buscar_zonas_recursivamente(no: Node, resultado: Array):
	if no is DropZone:
		resultado.append(no)
	
	for filho in no.get_children():
		_buscar_zonas_recursivamente(filho, resultado)

func retornar_para_posicao_original():
	# Voltar para o pai original
	get_tree().root.remove_child(self)
	_pai_original.add_child(self)
	position = _posicao_original_no_pai
	z_index = 0

func travar_em_posicao(posicao_global_alvo: Vector2):
	get_tree().root.remove_child(self)
	_pai_original.add_child(self)

	# Calcular posição local relativa ao pai original
	position = _pai_original.to_local(posicao_global_alvo) - (size / 2)

	_travado = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Feedback visual de sucesso
	modulate = Color(0.5, 1, 0.5)  # Verde claro
