# RelateChallenge.gd
extends "res://scripts/challenges/ChallengeBase.gd"

# Elementos da UI
var container_esquerda: VBoxContainer
var container_direita: VBoxContainer
var area_desenho: Control

# Variáveis do jogo
var itens_esquerda: Array = []
var itens_direita: Array = []
var conexoes_corretas: Array = []
var conexoes_feitas: Dictionary = {}
var conexoes_corretas_count: int = 0

# Estado de arrasto
var arrastando: bool = false
var ponto_origem_id: String = ""
var linha_inicio: Vector2

func _ready():
	print("RELATE CHALLENGE - Carregado")
	
	# Buscar nós
	if not container_esquerda:
		container_esquerda = find_child("LeftColumnContainer", true, false)
	if not container_direita:
		container_direita = find_child("RightColumnContainer", true, false)
	if not area_desenho:
		area_desenho = find_child("DrawingCanvas", true, false)
	
	super._ready()
	
	# Configurar área de desenho
	if area_desenho:
		area_desenho.gui_input.connect(_on_area_desenho_input)
		area_desenho.draw.connect(_on_area_desenho_draw)
		area_desenho.mouse_filter = Control.MOUSE_FILTER_PASS
		print("Área de desenho configurada")
	
	iniciar_com_dados()

func iniciar_com_dados():
	var dados = SceneManager.obter_dados_desafio_atual()
	if not dados.is_empty():
		print("Dados disponíveis no SceneManager")
		iniciar_desafio(dados)
	else:
		printerr("Nenhum dado de desafio recebido!")
		# Dados de fallback
		var dados_teste = {
			"id": "relate_test",
			"type": "relate",
			"title": "Relacione os Pares",
			"instructions": "Clique nos itens da esquerda e depois nos da direita para conectar",
			"items_left_column": [
				{"id": "jarro_barro", "text": "Jarro"},
				{"id": "botas_couro", "text": "Botas"},
				{"id": "chapeu_palha", "text": "Chapéu"}
			],
			"items_right_column": [
				{"id": "couro", "text": "Couro"},
				{"id": "barro", "text": "Barro"},
				{"id": "palha", "text": "Palha"}
			],
			"correct_connections": [
				{"left_id": "jarro_barro", "right_id": "barro"},
				{"left_id": "botas_couro", "right_id": "couro"},
				{"left_id": "chapeu_palha", "right_id": "palha"}
			]
		}
		iniciar_desafio(dados_teste)

func iniciar_desafio(dados: Dictionary):
	print("RelateChallenge.iniciar_desafio()")
	super.iniciar_desafio(dados)
	
	carregar_itens(dados)
	configurar_interface()

func carregar_itens(dados: Dictionary):
	itens_esquerda = dados.get("items_left_column", [])
	itens_direita = dados.get("items_right_column", [])
	conexoes_corretas = dados.get("correct_connections", [])
	conexoes_feitas.clear()
	conexoes_corretas_count = 0

func configurar_interface():
	print("Configurando interface...")
	
	# Limpar containers
	for filho in container_esquerda.get_children():
		filho.queue_free()
	for filho in container_direita.get_children():
		filho.queue_free()
	
	# Criar itens da esquerda (como botões clicáveis)
	for item_data in itens_esquerda:
		var botao = Button.new()
		botao.custom_minimum_size = Vector2(150, 60)
		botao.text = item_data.get("text", "Item")
		botao.set_meta("id", item_data["id"])
		botao.set_meta("lado", "esquerda")
		botao.pressed.connect(_on_item_esquerda_clicado.bind(item_data["id"]))
		container_esquerda.add_child(botao)
		print("Item esquerda: ", item_data["id"])
	
	# Criar itens da direita (como botões clicáveis)
	for item_data in itens_direita:
		var botao = Button.new()
		botao.custom_minimum_size = Vector2(150, 60)
		botao.text = item_data.get("text", "Item")
		botao.set_meta("id", item_data["id"])
		botao.set_meta("lado", "direita")
		botao.pressed.connect(_on_item_direita_clicado.bind(item_data["id"]))
		container_direita.add_child(botao)
		print("Item direita: ", item_data["id"])
	
	atualizar_progresso(0, conexoes_corretas.size())

func _on_item_esquerda_clicado(id_esquerda: String):
	print("Item esquerda clicado: ", id_esquerda)
	
	if not arrastando and not conexoes_feitas.has(id_esquerda):
		arrastando = true
		ponto_origem_id = id_esquerda
		
		# Encontrar o botão para posicionar a linha
		for botao in container_esquerda.get_children():
			if botao.get_meta("id") == id_esquerda:
				linha_inicio = botao.global_position + botao.size / 2
				botao.modulate = Color.YELLOW
				break
		
		print("Iniciando conexão de: ", id_esquerda)

func _on_item_direita_clicado(id_direita: String):
	print("Item direita clicado: ", id_direita)
	
	if arrastando and ponto_origem_id:
		_tentar_conectar(ponto_origem_id, id_direita)
		
		# Resetar estado
		arrastando = false
		
		# Resetar cor do botão de origem
		for botao in container_esquerda.get_children():
			if botao.get_meta("id") == ponto_origem_id:
				if conexoes_feitas.has(ponto_origem_id):
					botao.modulate = Color.GREEN
				else:
					botao.modulate = Color.WHITE
				break
		
		ponto_origem_id = ""
		area_desenho.queue_redraw()

func _on_area_desenho_input(event):
	# Se estiver arrastando, atualizar a linha temporária
	if arrastando and event is InputEventMouseMotion:
		area_desenho.queue_redraw()

func _tentar_conectar(id_origem: String, id_destino: String):
	print("Tentando conectar: ", id_origem, " → ", id_destino)
	
	# Verificar se já existe conexão
	if conexoes_feitas.has(id_origem) or _item_ja_conectado(id_destino):
		print("Um dos itens já está conectado")
		return
	
	# Verificar se a conexão é correta
	var conexao_correta = false
	for conexao in conexoes_corretas:
		if conexao["left_id"] == id_origem and conexao["right_id"] == id_destino:
			conexao_correta = true
			break
	
	if conexao_correta:
		# Conexão correta
		conexoes_feitas[id_origem] = id_destino
		conexoes_corretas_count += 1
		pontuacao += 20
		print("Conexão CORRETA! +20 pontos")
		
		# Destacar itens conectados
		_destacar_item_por_id(id_origem, Color.GREEN)
		_destacar_item_por_id(id_destino, Color.GREEN)
	else:
		# Conexão incorreta
		pontuacao = max(0, pontuacao - 5)
		print("Conexão INCORRETA! -5 pontos")
	
	atualizar_progresso(conexoes_corretas_count, conexoes_corretas.size())
	area_desenho.queue_redraw()
	
	# Verificar se completou
	if conexoes_corretas_count == conexoes_corretas.size():
		finalizar_relate()

func _item_ja_conectado(id_item: String) -> bool:
	for origem in conexoes_feitas:
		if conexoes_feitas[origem] == id_item:
			return true
	return false

func _destacar_item_por_id(id: String, cor: Color):
	# Buscar na esquerda
	for botao in container_esquerda.get_children():
		if botao.get_meta("id") == id:
			botao.modulate = cor
			return
	
	# Buscar na direita
	for botao in container_direita.get_children():
		if botao.get_meta("id") == id:
			botao.modulate = cor
			return

func _on_area_desenho_draw():
	print("Redesenhando área de desenho")
	
	# Obter a posição global da área de desenho
	var area_global_pos = area_desenho.global_position
	
	# Desenhar conexões permanentes
	for id_origem in conexoes_feitas:
		var id_destino = conexoes_feitas[id_origem]
		var botao_origem = _obter_botao_por_id(id_origem)
		var botao_destino = _obter_botao_por_id(id_destino)
		
		if botao_origem and botao_destino:
			# Obter as posições globais dos centros dos botões
			var inicio_global = botao_origem.global_position + botao_origem.size / 2
			var fim_global = botao_destino.global_position + botao_destino.size / 2
			
			# Converter para as coordenadas locais da área de desenho subtraindo a posição global da área de desenho
			var inicio_local = inicio_global - area_global_pos
			var fim_local = fim_global - area_global_pos
			
			# Desenhar linha verde
			area_desenho.draw_line(inicio_local, fim_local, Color.GREEN, 3)
			print("Desenhando linha: ", id_origem, " → ", id_destino)
	
	# Desenhar linha temporária durante arrasto
	if arrastando and ponto_origem_id:
		var botao_origem = _obter_botao_por_id(ponto_origem_id)
		if botao_origem:
			# Obter a posição global do centro do botão de origem
			var inicio_global = botao_origem.global_position + botao_origem.size / 2
			var fim_global = get_global_mouse_position()
			
			# Converter para as coordenadas locais da área de desenho
			var inicio_local = inicio_global - area_global_pos
			var fim_local = fim_global - area_global_pos
			
			area_desenho.draw_line(inicio_local, fim_local, Color.YELLOW, 2)
			print("Desenhando linha temporária")

func _obter_botao_por_id(id: String) -> Control:
	# Buscar na esquerda
	for botao in container_esquerda.get_children():
		if botao.get_meta("id") == id:
			return botao
	
	# Buscar na direita
	for botao in container_direita.get_children():
		if botao.get_meta("id") == id:
			return botao
	
	return null

func finalizar_relate():
	print("RELATE FINALIZADO!")
	print("   - Conexões: ", conexoes_corretas_count, "/", conexoes_corretas.size())
	
	var sucesso = conexoes_corretas_count == conexoes_corretas.size()
	
	var dados_resultado = {
		"tipo": "relate",
		"conexoes_corretas": conexoes_corretas_count,
		"total_conexoes": conexoes_corretas.size(),
		"precisao": int(float(conexoes_corretas_count) / conexoes_corretas.size() * 100)
	}
	
	finalizar_desafio(sucesso, dados_resultado)
