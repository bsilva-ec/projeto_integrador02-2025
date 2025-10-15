# SceneManager.gd 
extends Node

var dados_desafio_temp: Dictionary = {}
var dados_fase_temp: Dictionary = {}
var desafios_da_fase: Array = []
var desafio_atual_index: int = 0
var id_fase_temp: String = ""

func get_id_fase_temp() -> String:
	return id_fase_temp

func preparar_fase(dados_fase: Dictionary, id_fase: String):
	dados_fase_temp = dados_fase.duplicate(true)
	desafios_da_fase = dados_fase["challenges"].duplicate(true)
	desafio_atual_index = 0
	id_fase_temp = id_fase
	
	print("SceneManager: Fase preparada")
	print("   - ID Fase: ", id_fase)
	print("   - Total desafios: ", desafios_da_fase.size())

func obter_proximo_desafio() -> Dictionary:
	if desafio_atual_index >= desafios_da_fase.size():
		print("SceneManager: Todos os desafios foram concluídos")
		return {}
	
	var desafio = desafios_da_fase[desafio_atual_index]
	print("SceneManager: Entregando desafio ", desafio_atual_index + 1, " de ", desafios_da_fase.size())
	print("   - Tipo: ", desafio["type"])
	print("   - ID: ", desafio["id"])
	
	return desafio

func avancar_para_proximo_desafio():
	desafio_atual_index += 1
	print("SceneManager: Avançando para desafio ", desafio_atual_index + 1, " de ", desafios_da_fase.size())

func tem_mais_desafios() -> bool:
	return desafio_atual_index < desafios_da_fase.size()

func limpar_dados():
	print("SceneManager: Dados limpos")
	dados_desafio_temp = {}
	desafios_da_fase = []
	desafio_atual_index = 0
	id_fase_temp = ""

func obter_dados_desafio_atual() -> Dictionary:
	return dados_desafio_temp

func preparar_desafio_especifico(dados: Dictionary):
	dados_desafio_temp = dados.duplicate(true)
	print("SceneManager: Dados do desafio preparados")
	print("   - ID: ", dados.get("id", "sem_id"))
	print("   - Tipo: ", dados.get("type", "desconhecido"))
