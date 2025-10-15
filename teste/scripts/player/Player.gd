# Player.gd
class_name Player
extends Resource

const CAMINHO_SALVAMENTO = "user://saves/"
const PREFIXO_ARQUIVO = "aluno_"
const EXTENSAO_ARQUIVO = ".json"

@export var id: String = ""
@export var student_name: String = ""
@export var pontuacao_total: int = 0
@export var progresso: Dictionary = {}

func _init(nome_aluno: String = ""):
	if not nome_aluno.is_empty():
		student_name = nome_aluno
		id = str(Time.get_unix_time_from_system()) + "_" + str(randi() % 10000)

func salvar() -> bool:
	var caminho_arquivo = CAMINHO_SALVAMENTO + PREFIXO_ARQUIVO + student_name.to_lower().strip_edges() + EXTENSAO_ARQUIVO
	
	var arquivo = FileAccess.open(caminho_arquivo, FileAccess.WRITE)
	if arquivo:
		var string_json = JSON.stringify(serializar(), "\t")
		arquivo.store_string(string_json)
		print("Perfil de aluno salvo: ", student_name)
		return true
	else:
		printerr("Falha ao salvar perfil de aluno: ", student_name)
		return false

static func load(nome_aluno: String) -> Player:
	var caminho_arquivo = CAMINHO_SALVAMENTO + PREFIXO_ARQUIVO + nome_aluno.to_lower().strip_edges() + EXTENSAO_ARQUIVO
	if not FileAccess.file_exists(caminho_arquivo):
		return null
	
	var arquivo = FileAccess.open(caminho_arquivo, FileAccess.READ)
	var conteudo = arquivo.get_as_text()
	var dados_json = JSON.parse_string(conteudo)
	
	if dados_json is Dictionary:
		var aluno_carregado = Player.new()
		aluno_carregado.id = dados_json.get("id", "")
		aluno_carregado.student_name = dados_json.get("name", "")
		aluno_carregado.pontuacao_total = dados_json.get("total_score", 0)
		aluno_carregado.progresso = dados_json.get("progress", {})
		print("Perfil de aluno carregado: ", nome_aluno)
		return aluno_carregado
	
	return null

static func perfil_existe(nome_aluno: String) -> bool:
	var caminho_arquivo = CAMINHO_SALVAMENTO + PREFIXO_ARQUIVO + nome_aluno.to_lower().strip_edges() + EXTENSAO_ARQUIVO
	return FileAccess.file_exists(caminho_arquivo)

func serializar() -> Dictionary:
	return {
		"id": id,
		"name": student_name,
		"total_score": pontuacao_total,
		"progress": progresso
	}
