# ChallengeDataManager.gd
extends Node

var fases_data: Dictionary
var quiz_data: Dictionary
var relate_data: Dictionary
var dragdrop_data: Dictionary

func _ready():
	fases_data = _carregar_json("res://data/levels/fases.json")
	quiz_data = _carregar_json("res://data/levels/quiz.json")
	relate_data = _carregar_json("res://data/levels/relate.json")
	dragdrop_data = _carregar_json("res://data/levels/dragdrop.json")

func _carregar_json(caminho: String) -> Dictionary:
	var arquivo = FileAccess.open(caminho, FileAccess.READ)
	if arquivo == null:
		print("Erro: Arquivo não encontrado: ", caminho)
		return {}
	
	var conteudo = arquivo.get_as_text()
	arquivo.close()
	
	var json = JSON.new()
	var erro = json.parse(conteudo)
	if erro != OK:
		print("ERRO no JSON ", caminho, " - Linha ", json.get_error_line(), ": ", json.get_error_message())
		return {}
	
	return json.get_data()

func get_challenges_for_phase(id_fase: String) -> Array:
	print("Buscando desafios para fase: ", id_fase)
	
	if not fases_data.has(id_fase):
		print("Fase não encontrada: ", id_fase)
		return []
	
	var info_fase = fases_data[id_fase]
	var ponteiros_desafios = info_fase["challenges"]
	var lista_desafios_completa = []
	
	print("Pointers encontrados: ", ponteiros_desafios)
	
	for ponteiro in ponteiros_desafios:
		var tipo_desafio = ponteiro["type"]
		var id_desafio = ponteiro["id"]
		var dados_desafio = {}
		
		print("Processando: tipo=", tipo_desafio, ", id=", id_desafio)
		
		match tipo_desafio:
			"quiz":
				if quiz_data.has(id_desafio):
					dados_desafio = quiz_data[id_desafio].duplicate(true)
			"relate":
				if relate_data.has(id_desafio):
					dados_desafio = relate_data[id_desafio].duplicate(true)
			"dragdrop":
				if dragdrop_data.has(id_desafio):
					dados_desafio = dragdrop_data[id_desafio].duplicate(true)
				else:
					print("AVISO: Dados de dragdrop não encontrados, usando quiz como fallback")
					tipo_desafio = "quiz"
					if quiz_data.has(id_desafio):
						dados_desafio = quiz_data[id_desafio].duplicate(true)
		
		if not dados_desafio.is_empty():
			dados_desafio["type"] = tipo_desafio
			dados_desafio["id"] = id_desafio
			lista_desafios_completa.append(dados_desafio)
			print("Desafio adicionado: ", id_desafio)
		else:
			print("AVISO: Desafio não encontrado, pulando: ", id_desafio)
	
	print("Total de desafios carregados: ", lista_desafios_completa.size())
	return lista_desafios_completa
