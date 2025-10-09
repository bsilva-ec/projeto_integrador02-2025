# WorldMap.gd
extends Control

@onready var student_name_label: Label = $StudentHUD/HBoxContainer/StudentNameLabel
@onready var score_label: Label = $StudentHUD/HBoxContainer/ScoreLabel
@onready var theme_title_label: Label = $ThemeTitleLabel
@onready var theme_viewer = $ThemeViewer
@onready var previous_button = $PreviousThemeButton
@onready var next_button = $NextThemeButton

# Vamos guardar nossos temas em um array para facilitar a navegação
var themes: Array = []
var current_theme_index: int = 0

func _ready():
	# Conecta os sinais dos botões de navegação
	previous_button.pressed.connect(_on_previous_theme_pressed)
	next_button.pressed.connect(_on_next_theme_pressed)
	
	# Pega todos os nós de tema (filhos do ThemeViewer) e os coloca no nosso array
	for theme_node in theme_viewer.get_children():
		themes.append(theme_node)
		# Conecta todos os botões de fase dentro de cada tema
		for phase_button in theme_node.get_children():
			if phase_button is Button:
				# O nome do botão será o ID da fase!
				var phase_id = phase_button.name
				phase_button.pressed.connect(_on_phase_button_pressed.bind(phase_id))

	update_student_info()
	_update_theme_display()


# Atualiza a UI com os dados do aluno que fez "login"
func update_student_info():
	if GameManager.current_student_data:
		student_name_label.text = "Aluno: " + GameManager.current_student_data.get("name", "N/A")
		score_label.text = "Pontuação: " + str(GameManager.current_student_data.get("total_score", 0))

# A função principal que mostra o tema correto e esconde os outros
func _update_theme_display():
	for i in themes.size():
		var theme = themes[i]
		if i == current_theme_index:
			theme.visible = true
			# Atualiza o título. Ex: "Theme_Sistema_Solar" vira "Sistema Solar"
			theme_title_label.text = theme.name.replace("Theme_", "").replace("_", " ")
		else:
			theme.visible = false
			
# Chamado quando o botão ">" é pressionado
func _on_next_theme_pressed():
	current_theme_index = (current_theme_index + 1) % themes.size()
	_update_theme_display()

# Chamado quando o botão "<" é pressionado
func _on_previous_theme_pressed():
	current_theme_index -= 1
	if current_theme_index < 0:
		current_theme_index = themes.size() - 1
	_update_theme_display()

# Chamado quando um botão de FASE (dentro de um tema) é pressionado
func _on_phase_button_pressed(phase_id: String):
	print("Iniciando fase: ", phase_id)
	
	GameManager.set_current_phase_id(phase_id)
	get_tree().change_scene_to_file("res://scenes/Main.tscn")
