# GameManager.gd
extends Node

# Singleton do GameManager
static var instance: GameManager

# Dados do jogador atual
var jogador_atual: Dictionary = {
	"nome": "",
	"pontuacao": 0,
	"fases_completadas": [],
	"desafios_completados": []
}

# Lista de todos os jogadores
var todos_jogadores: Dictionary = {}

# Dados da sessão atual
var fase_atual: String = ""

func _ready():
	# Configurar singleton
	if instance == null:
		instance = self
		process_mode = Node.PROCESS_MODE_ALWAYS
		carregar_todos_jogadores()
	else:
		queue_free()
	
	print("GAME MANAGER - Inicializado")

# Gerenciamento de jogadores
func criar_jogador(nome: String) -> bool:
	if todos_jogadores.has(nome):
		print("Jogador já existe: ", nome)
		return false
	
	var novo_jogador = {
		"nome": nome,
		"pontuacao": 0,
		"fases_completadas": [],
		"desafios_completados": [],
		"data_criacao": Time.get_datetime_string_from_system()
	}
	
	todos_jogadores[nome] = novo_jogador
	salvar_todos_jogadores()
	print("Novo jogador criado: ", nome)
	return true

func carregar_jogador(nome: String) -> bool:
	if todos_jogadores.has(nome):
		jogador_atual = todos_jogadores[nome].duplicate(true)
		print("Jogador carregado: ", nome)
		return true
	else:
		print("Jogador não encontrado: ", nome)
		return false

func obter_todos_jogadores() -> Array:
	var lista_jogadores = []
	for nome_jogador in todos_jogadores:
		lista_jogadores.append(todos_jogadores[nome_jogador])
	return lista_jogadores

func obter_pontuacao_jogador() -> int:
	return jogador_atual.get("pontuacao", 0)

func atualizar_pontuacao_jogador(pontos: int, dados_desafio: Dictionary = {}):
	jogador_atual["pontuacao"] += pontos
	
	# Registrar desafio completado se for bem-sucedido
	if dados_desafio.get("sucesso", false):
		var desafio_id = dados_desafio.get("id", "")
		if desafio_id and not jogador_atual["desafios_completados"].has(desafio_id):
			jogador_atual["desafios_completados"].append(desafio_id)
	
	salvar_todos_jogadores()
	print("Pontuação atualizada: +", pontos, " pontos (Total: ", jogador_atual["pontuacao"], ")")

# Sistema de save/load
func salvar_todos_jogadores():
	var save_data = {
		"todos_jogadores": todos_jogadores,
		"ultimo_jogador": jogador_atual.get("nome", "")
	}
	
	var arquivo = FileAccess.open("user://jogadores.dat", FileAccess.WRITE)
	if arquivo:
		arquivo.store_var(save_data)
		print("Jogadores salvos com sucesso!")
	else:
		printerr("Erro ao salvar jogadores!")

func carregar_todos_jogadores():
	var arquivo = FileAccess.open("user://jogadores.dat", FileAccess.READ)
	if arquivo:
		var save_data = arquivo.get_var()
		todos_jogadores = save_data.get("todos_jogadores", {})
		
		# Tentar carregar último jogador usado
		var ultimo_jogador = save_data.get("ultimo_jogador", "")
		if ultimo_jogador and todos_jogadores.has(ultimo_jogador):
			carregar_jogador(ultimo_jogador)
		
		print("Jogadores carregados: ", todos_jogadores.size())
	else:
		print("Nenhum save encontrado, iniciando com dados vazios")
		todos_jogadores = {}

# Gerenciamento de fases
func completar_fase(fase_id: String):
	if not jogador_atual["fases_completadas"].has(fase_id):
		jogador_atual["fases_completadas"].append(fase_id)
		jogador_atual["pontuacao"] += 100  # Bônus por completar fase
		salvar_todos_jogadores()
		print("Fase completada: ", fase_id, " +100 pontos")

func is_fase_completada(fase_id: String) -> bool:
	return jogador_atual["fases_completadas"].has(fase_id)

# Utilitários
func resetar_jogo():
	jogador_atual = {
		"nome": "",
		"pontuacao": 0,
		"fases_completadas": [],
		"desafios_completados": []
	}
	todos_jogadores = {}
	
	# Deletar arquivo de save
	var dir = DirAccess.open("user://")
	if dir.file_exists("user://jogadores.dat"):
		dir.remove("user://jogadores.dat")
	
	print("Progresso do jogo resetado")

func get_jogador_atual_nome() -> String:
	return jogador_atual.get("nome", "Nenhum jogador")
