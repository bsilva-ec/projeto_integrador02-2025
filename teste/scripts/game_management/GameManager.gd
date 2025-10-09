# GameManager.gd
extends Node

# Variáveis para armazenar o estado do jogo e do aluno atual
var current_student_data: Dictionary = {} # Dados do aluno
var game_progression_data: Dictionary = {} # Progresso do jogo

var current_challenge_node: Control # Para manter referência ao desafio atual

# Caminho onde os arquivos do save dos alunos serãp armazenados
const SAVE_PATH = "user://saves/"
const STUDENT_DATA_FILE_PREFIX = "aluno_"
const FILE_EXTENSION = ".json"

# Signal
# São emitidos quando os dados do aluno ativo são carregados/atualizados
signal student_data_loaded(student_data)
signal student_data_updated(student_data)
# Emitido quando uma fase é completada
signal phase_completed(phase_id, score, is_success)

func _ready():
	# Conferir se a pasta de saves existe
	var dir = DirAccess.open(SAVE_PATH)
	if not dir:
		DirAccess.make_dir_absolute(SAVE_PATH)
	print("GameManager initialized. Save path: ", ProjectSettings.globalize_path(SAVE_PATH))

# Métodos de Gerenciamento do Aluno

# Carrega os dados de um aluno específico pelo nome
func load_student_profile(student_name: String) -> bool:
	var file_path = SAVE_PATH + STUDENT_DATA_FILE_PREFIX + student_name.to_lower().strip_edges() + FILE_EXTENSION
	var file = FileAccess.open(file_path, FileAccess.READ)
	
	if file:
		var content = file.get_as_text()
		file.close()
		var json_data = JSON.parse_string(content)
		if json_data is Dictionary:
			current_student_data = json_data
			game_progression_data = current_student_data.get("progress", {})
			student_data_loaded.emit(current_student_data)
			print("Student profile loaded: ", student_name)
			return true
		else:
			printerr("Failed to parse student data for: ", student_name)
			return false
	else:
		print("Student profile not found: ", student_name)
		return false

# Salva os dados do aluno ativo
func save_current_student_profile() -> bool:
	if current_student_data.is_empty():
		printerr("No student data to save.")
		return false
	
	# Atualiza os dados de progresso dentro dos dados do aluno
	current_student_data["progress"] = game_progression_data
	
	var student_name = current_student_data.get("name", "unknown").to_lower().strip_edges()
	var file_path = SAVE_PATH + STUDENT_DATA_FILE_PREFIX + student_name + FILE_EXTENSION
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	
	if file:
		var json_string = JSON.stringify(current_student_data, "\t")
		file.store_string(json_string)
		file.close()
		print("Student profile saved: ", student_name)
		student_data_updated.emit(current_student_data)
		return true
	else:
		printerr("Failed to save student profile: ", student_name)
		return false

# Cria um novo perfil de aluno
func create_new_student_profile(new_student_name: String) -> bool:
	if new_student_name.is_empty():
		printerr("Student name cannot be empty.")
		return false
	
	var student_name_lower = new_student_name.to_lower().strip_edges()
	var file_path = SAVE_PATH + STUDENT_DATA_FILE_PREFIX + student_name_lower + FILE_EXTENSION
	
	if FileAccess.file_exists(file_path):
		printerr("Student profile already exists: ", new_student_name)
		return false
		
	current_student_data = {
		"name": new_student_name,
		"id": generate_unique_id(), # Implementar uma função para gerar IDs únicos
		"total_score": 0,
		"total_progress": 0.0, # 0.0 a 1.0 ou %
		"progress": {} # Armazenará o progresso de cada fase
	}
	game_progression_data = {}
	
	return save_current_student_profile()

# Métodos de Gerenciamento de Progresso

# Atualiza o progresso de uma fase específica
func update_phase_progress(phase_id: String, score: int, is_success: bool, attempts: int, time_spent: float, additional_data: Dictionary = {}) -> void:
	if current_student_data.is_empty():
		printerr("No student logged in to update phase progress.")
		return
	
	var phase_entry = game_progression_data.get(phase_id, {})
	phase_entry["score"] = score
	phase_entry["is_sucess"] = is_success
	phase_entry["attempts"] = attempts
	phase_entry["time_spent"] = time_spent
	phase_entry["completed_at"] = Time.get_datetime_string_from_system()
	# Mesclar quaisquer dados adicionais (ex: lista de erros específicos)
	for key in additional_data:
		phase_entry[key] = additional_data[key]
	
	game_progression_data[phase_id] = phase_entry
	
	#Atualizar pontuação total e progresso total (ex: somat scores, calcular % de fases completadas)
	current_student_data["total_score"] = current_student_data.get("total_score", 0) + score
	# Lógica para recalcular total_progress, talvez contando fases únicas completadas
	
	save_current_student_profile()
	phase_completed.emit(phase_id, score, is_success)
	
# Verifica se uma fase foi completada por um aluno
func is_phase_completed(phase_id: String) -> bool:
	return game_progression_data.has(phase_id) and game_progression_data[phase_id].get("is_success", false)

# Retorna o progresso de uma fase específica
func get_phase_progress(phase_id: String) -> Dictionary:
	return game_progression_data.get(phase_id, {})

# Retorna todos os dados de progresso do aluno logado
func get_all_student_progress() -> Dictionary:
	return game_progression_data

# Métodos de Utilidade

# Função placeholder para gerar um ID único (melhorar para algo mais robusto)
func generate_unique_id() -> String:
	return str(Time.get_unix_time_from_system()) + "_" + str(randi() % 10000)

# Função para obter dados de todos os alunos para o Dashboard do Professor
func get_all_students_for_dashboard() -> Array:
	var students_data_list: Array = []
	var dir = DirAccess.open(SAVE_PATH)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(FILE_EXTENSION) and file_name.begins_with(STUDENT_DATA_FILE_PREFIX):
				var _student_name_from_file = file_name.replace(STUDENT_DATA_FILE_PREFIX, "").replace(FILE_EXTENSION, "")
				var file_path = SAVE_PATH + file_name
				var file = FileAccess.open(file_path, FileAccess.READ)
				if file:
					var content = file.get_as_text()
					file.close()
					var json_data = JSON.parse_string(content)
					if json_data is Dictionary:
						students_data_list.append(json_data)
			file_name = dir.get_next()
		dir.list_dir_end()
	return students_data_list

# Funções para gerenciar as fases

var current_phase_id: String
var current_phase_challenges: Array
var challenge_index: int = 0

# Função para iniciar uma fase
func start_phase(phase_id: String, container_node: Node):
	# container_node é o nó da cena onde os desafios serão adicionados
	# Pega a lista de desafios para a fase
	current_phase_id = phase_id
	current_phase_challenges = ChallengeDataManager.get_challenges_for_phase(phase_id)
	# Randomiza a ordem
	current_phase_challenges.shuffle()
	
	challenge_index = 0
	_play_next_challenge(container_node)

func _play_next_challenge(container_node: Node):
	if challenge_index >= current_phase_challenges.size():
		print("Fase Concluída!")
		phase_completed.emit(current_phase_id, 0, true)
		# Ir para a tela de resultados, etc.
		return
	
	var challenge_data = current_phase_challenges[challenge_index]
	var challenge_type = challenge_data.get("type", "")
	
	# Carrega a cena correta baseado no tipo de dasafio
	var scene_path = ""
	match challenge_type:
		"quiz":
			scene_path = "res://scenes/challenges/QuizChallenge.tscn"
			pass
		"relate":
			scene_path = "res://scenes/challenges/RelateChallenge.tscn"
			pass
		"dragdrop":
			scene_path = "res://scenes/challenges/DragDropChallenge.tscn"
			pass
	
	if scene_path.is_empty():
		print("AVISO: Cena não definida para o tipo '", challenge_type, "'. Pulando.")
		challenge_index += 1
		_play_next_challenge(container_node)
		return
	
	# Instancia, conecta o sinal e adiciona o desafio
	var challenge_scene = load(scene_path).instantiate()
	current_challenge_node = challenge_scene
	container_node.add_child(current_challenge_node)
		
	# Conexão
	current_challenge_node.challenge_finished.connect(_on_challenge_finished.bind(container_node))
	
	# Passa os dados usando a nova conexão
	current_challenge_node.setup_challenge(challenge_data)
	
	challenge_index += 1

func _on_challenge_finished(id, score, is_success, additional_data, container_node: Node):
	print(str("Desafio ", id, " finalizado!"))
	
	# Atualiza o progresso do aluno
	# O 'id' aqui pode ser o id da FASE, não do mini-desafio.
	# Precisará ajustar como o progresso é salvo (por fase ou por mini-desafio).
	# update_phase_progress(...)
	var challenge_node = current_challenge_node as ChallengeBase
	if challenge_node:
		update_phase_progress(
			current_phase_id,
			score,
			is_success,
			challenge_node._attempts,
			challenge_node._time_spent,
			additional_data
		)
	
	# Chama o próximo desafio
	_play_next_challenge(container_node)
