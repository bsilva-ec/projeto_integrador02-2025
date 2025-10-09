# FlowManager
extends Node

# Caminhos das cenas
# Cenas principais
const SCENE_MAIN_MENU = "res://scenes/UI/MainMenu.tscn"
const SCENE_PLAYER_LOGIN = "res://scenes/GameFlow/PlayerLogin.tscn"
const SCENE_WORLD_MAP = "res://scenes/GameFlow/WorldMap.tscn"
const SCENE_TEACHER_DASHBOARD = "res://scenes/GameFlow/TeacherDashboard.tscn"

# Dicionário para mapear IDs de fases e seus caminhos de cena
var level_scene_paths: Dictionary = {
	# Adicione aqui todas as fases/desafios
}

# Signals
# Emitido quando uma transição de cena começa
signal scene_transition_started(scene_path)
# Emitido quando uma transição de cena termina
signal scene_transition_finished(scene_path)

# Métodos de navegação
#Método genérico para mudar para qualquer cena
func change_scene(scene_path: String) -> void:
	if not ResourceLoader.exists(scene_path, "PackedScene"):
		printerr("FlowManager: Scene path does not exist: ", scene_path)
		return
	
	scene_transition_started.emit(scene_path)
	print("FlowManager: Changing scene to: ", scene_path)
	#get_tree().change_scene_to_file(scene_path) # Método direto
	
	# Para uma transição mais suave, considere carregar assincronamente
	var current_scene = get_tree().current_scene
	if current_scene:
		current_scene.queue_free() # Libera a cena atual
	
	var next_scene_packed = load(scene_path)
	var next_scene = next_scene_packed.instantiate()
	get_tree().root.add_child(next_scene)
	get_tree().current_scene = next_scene
	
	scene_transition_finished.emit(scene_path)

# Método específicos para as principais telas do jogo
func goto_main_menu() -> void:
	change_scene(SCENE_MAIN_MENU)

func goto_player_login() -> void:
	change_scene(SCENE_PLAYER_LOGIN)

func goto_world_map() -> void:
	change_scene(SCENE_WORLD_MAP)

func goto_teacher_dashboard() -> void:
	change_scene(SCENE_TEACHER_DASHBOARD)

# Método para carregar um cena de fase dinamicamente pelo ID
func goto_level(level_id: String) -> void:
	if level_scene_paths.has(level_id):
		change_scene(level_scene_paths[level_id])
	else:
		printerr("FlowManager: Level ID not found: ", level_id)

# --- Métodos de Transição (Opcional, para uma experiência mais polida) ---
# Você pode implementar aqui animações de fade, cortinas, etc.
# Exemplo:
# var _transition_scene_instance: Node = null
#
# func _start_transition(fade_time: float = 0.5):
#	_transition_scene_instance = load("res://Scenes/UI/TransitionScreen.tscn").instantiate()
#	get_tree().root.add_child(_transition_scene_instance)
#	# Inicia animação de fade in
#	await get_tree().create_timer(fade_time).timeout
#
# func _end_transition(fade_time: float = 0.5):
# 	# Inicia animação de fade out
# 	await get_tree().create_timer(fade_time).timeout
# 	if _transition_scene_instance:
# 		_transition_scene_instance.queue_free()
# 		_transition_scene_instance = null
#
# # E então, em change_scene, você faria:
# # await _start_transition()
# # get_tree().change_scene_to_file(scene_path)
# # await _end_transition()
