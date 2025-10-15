# Player.gd
class_name Player
extends Resource

@export var nome: String = ""
@export var pontuacao_total: int = 0
@export var progresso: Dictionary = {}

func _init(nome_jogador: String = ""):
	nome = nome_jogador

func salvar() -> bool:
	var caminho = "user://saves/jogador_" + nome.to_lower() + ".json"
	var arquivo = FileAccess.open(caminho, FileAccess.WRITE)
	
	if arquivo:
		var dados = {
			"nome": nome,
			"pontuacao_total": pontuacao_total,
			"progresso": progresso
		}
		arquivo.store_string(JSON.stringify(dados))
		print("Jogador salvo: ", nome)
		return true
	
	printerr("Falha ao salvar jogador: ", nome)
	return false

static func carregar(nome_jogador: String) -> Player:
	var caminho = "user://saves/jogador_" + nome_jogador.to_lower() + ".json"
	
	if not FileAccess.file_exists(caminho):
		return null
	
	var arquivo = FileAccess.open(caminho, FileAccess.READ)
	var dados = JSON.parse_string(arquivo.get_as_text())
	
	if dados is Dictionary:
		var jogador = Player.new()
		jogador.nome = dados.get("nome", "")
		jogador.pontuacao_total = dados.get("pontuacao_total", 0)
		jogador.progresso = dados.get("progresso", {})
		print("Jogador carregado: ", nome_jogador)
		return jogador
	
	return null

static func existe(nome_jogador: String) -> bool:
	var caminho = "user://saves/jogador_" + nome_jogador.to_lower() + ".json"
	return FileAccess.file_exists(caminho)
