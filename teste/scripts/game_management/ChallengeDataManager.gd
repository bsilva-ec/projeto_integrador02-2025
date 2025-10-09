# ChallengeDataManager.gd
extends Node

var fases_data: Dictionary
var quiz_data: Dictionary
var relate_data: Dictionary
var dragdrop_data: Dictionary

func _ready(): 
	# Na versão final, seria carregado os JSONs aqui
	# Por enquanto, vamos simular com os dados direto no script
	fases_data = carregar_json("res://data/fases.json")
	quiz_data = carregar_json("res://data/quiz.json")
	relate_data = carregar_json("res://data/relate.json")
	dragdrop_data = carregar_json("res://data/dragdrop.json")

# Função para carregar e parsear um arquivo JSON
func carregar_json(path: String) -> Dictionary:
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		print("Erro ao abrir o arquivo JSON: ", path)
		return {}
	var content = file.get_as_text()
	var json = JSON.new()
	var error = json.parse(content)
	if error != OK:
		print("Erro ao parsear o JSON: ", json.get_error_message())
		return {}
	return json.get_data()

# Função principal, ela monta a lista completa de desafios para uma nova fase específica.
func get_challenges_for_phase(phase_id: String) -> Array:
	if not fases_data.has(phase_id):
		print("Fase não encontrada: ", phase_id)
		return []
	
	var phase_info = fases_data[phase_id]
	var challenge_pointers = phase_info["challenges"]
	var full_challenge_list = []
	
	for pointer in challenge_pointers:
		var challenge_type = pointer["type"]
		var challenge_id = pointer["id"]
		var challenge_data = {}
		
		match challenge_type:
			"quiz":
				if quiz_data.has(challenge_id):
					challenge_data = quiz_data[challenge_id].duplicate(true)
			"relate":
				if relate_data.has(challenge_id):
					challenge_data = relate_data[challenge_id].duplicate(true)
			"dragdrop":
				if dragdrop_data.has(challenge_id):
					challenge_id = dragdrop_data[challenge_id].duplicate(true)
		
		if not challenge_data.is_empty():
			# MUITO IMPORTANTE: Adicionamos o tipo ao desafio!
			# Assim, o GameManager saberá qual cena carregar.
			challenge_data["type"] = challenge_type
			full_challenge_list.append(challenge_data)
		else:
			print("Desafio não encontrado: tipo=", challenge_type, ", id=", challenge_id)
	
	return full_challenge_list
