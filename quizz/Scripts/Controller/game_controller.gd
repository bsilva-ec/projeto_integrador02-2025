extends Node

@export var temasQuestoes: Array[themes]
@export var color_right: Color
@export var color_wrong: Color
@export var Menu_Inicial: Array[MenuInicial]

var buttonsQuestion: Array[Button]
var buttonsMenuInitial: Array[Button]
var buttonsThemes: Array[Button]
var ThemeIndex: int
var QuestionIndex: int
var MenuIndex: int
var correct: int
var themeSelected: themes
#tela das questoes
@onready var question_select: Control = $Question_select
@onready var question_options: VBoxContainer = $Question_select/QuestionOptions
@onready var question_text: Label = $Question_select/QuestionStatement/QuestionText
@onready var question_image: Panel = $Question_select/QuestionStatement/QuestionImage


#tela de seleção de tema
@onready var select_theme: Control = $Select_theme
@onready var tema_1: Button = $Select_theme/VBoxThemes/Tema1
@onready var tema_2: Button = $Select_theme/VBoxThemes/Tema2

#tela start
@onready var start_game: Control = $StartGame
@onready var start_button: Button = $StartGame/Start_button
@onready var config_button: Button = $StartGame/ConfigButton
@onready var exit_button: Button = $StartGame/ExitButton

func _ready() -> void:
	for buttons in $Question_select/QuestionOptions.get_children():
		buttonsQuestion.append(buttons)
		
	for buttons in $StartGame/InitialMenuButtons.get_children():
		buttonsMenuInitial.append(buttons)
		
	for buttons in $Select_theme/VBoxThemes.get_children():
		buttonsThemes.append(buttons)
	StartGame()
	pass

func HideScreens():
	$StartGame.hide()
	$Question_select.hide()
	$Select_theme.hide()

func StartGame() ->void:
	for i in buttonsMenuInitial.size():
		buttonsMenuInitial[i].pressed.connect(buttonsMenuInitialSelect.bind(buttonsMenuInitial[i]))
		
#função para fazer a verificação de qual botao foi clicado e chamar 
#a função correspondente.
func buttonsMenuInitialSelect(button) ->void:
	#esconde todas as telas ao clicar em qualquer botao
	HideScreens()
	#variavel para identificar o indice do botao que foi clicado
	var index = buttonsMenuInitial.find(button)
	#verifica qual indice foi clicado e chama a função correspondente
	match index:
		0:
			LoadThemeSelected()
		1: 
			LoadSettings()
		2:
			get_tree().quit()
	
#carrega a lista de temas
func  LoadThemeSelected() ->void:
	$Select_theme.show()
	for i in buttonsThemes.size():
		buttonsThemes[i].pressed.connect(ButtonsThemeSelected.bind(buttonsThemes[i]))
		
func ButtonsThemeSelected(button) ->void:
	#esconde as telas ao clicar em uma opção
	HideScreens()
	#variavel para identificar o indice do botao que foi clicado
	var index = buttonsThemes.find(button)
	# atribui valor ao indice do tema selecionado
	#chama a função com as questões correspondentes 
	match index:
		0:
			ThemeIndex = 0
			LoadQuiz()
		1:
			ThemeIndex = 1
			LoadQuiz()
		2:
			ThemeIndex = 2
			LoadQuiz()
	
func LoadQuiz() ->void:
	if QuestionIndex >= temasQuestoes[ThemeIndex].ThemeQuestion.size():
		return
	$Question_select.show()
	#implementação dos enunciados 
	question_text.text = temasQuestoes[ThemeIndex].ThemeQuestion[QuestionIndex].Statement
	#implementação das questões
	for i in buttonsQuestion.size():
		buttonsQuestion[i].text = temasQuestoes[ThemeIndex].ThemeQuestion[QuestionIndex].Options[i]
		buttonsQuestion[i].pressed.connect(buttonsAnswer.bind(buttonsQuestion[i]))
		
	if  temasQuestoes[ThemeIndex].ThemeQuestion[QuestionIndex].QuestionImage == null:
		$Question_select/QuestionStatement/QuestionImage.hide()
	else:
		$Question_select/QuestionStatement/QuestionImage.show()
		
func buttonsAnswer(button) ->void:
	print(button.text)
	if temasQuestoes[ThemeIndex].ThemeQuestion[QuestionIndex].correct == button.text:
		button.modulate = color_right
	else:
		button.modulate = color_wrong
		
	NextQuestion()
	
func NextQuestion() -> void:
	for i in buttonsQuestion:
		i.pressed.disconnect(buttonsAnswer) 
	await get_tree().create_timer(1).timeout
	for i in buttonsQuestion:
		i.modulate = Color.WHITE 
		
	QuestionIndex +=1
		
	LoadQuiz()
func LoadSettings() ->void:
	#ativar e desativar som
	pass
