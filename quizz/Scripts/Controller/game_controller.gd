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
var score: int
var themeSelected: themes
var QtdQuestions: int = 8
#tela das questoes
@onready var question_select: Control = $Question_select
@onready var question_options: VBoxContainer = $Question_select/QuestionOptions
@onready var question_text: Label = $Question_select/QuestionStatement/QuestionText
@onready var question_image: Panel = $Question_select/QuestionStatement/QuestionImage


#tela de seleção de tema
@onready var select_theme: Control = $Select_theme
@onready var tema_1: Button = $Select_theme/VBoxThemes/Tema1
@onready var tema_2: Button = $Select_theme/VBoxThemes/Tema2
@onready var tema_3: Button = $Select_theme/VBoxThemes/Tema3

#tela start
@onready var start_game: Control = $StartGame
@onready var InsertName = $StartGame/Name
@onready var config_button: Button = $StartGame/ConfigButton
@onready var exit_button: Button = $StartGame/ExitButton
@onready var start_button: Button = $StartGame/InitialMenuButtons/Start_button

func _ready() -> void:
	
	start_button.disabled = true
	
	score = 0
	for buttons in $Question_select.get_children():
		buttonsQuestion.append(buttons)
		
	for buttons in $StartGame/InitialMenuButtons.get_children():
		buttonsMenuInitial.append(buttons)
		
	for buttons in $Select_theme.get_children():
		buttonsThemes.append(buttons)
	
	StartGame()
	

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
			
	temasQuestoes[ThemeIndex].ThemeQuestion.shuffle()
	QuestionIndex = 0
	LoadQuiz()
	
func LoadQuiz() ->void:
	if QuestionIndex >= QtdQuestions:
		GameOver()
		$Question_select.hide()
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
		score +=1
	else:
		button.modulate = color_wrong
		
	NextQuestionQuiz()
#função para preparar o quiz para a proxima questão
func NextQuestionQuiz() -> void:
	#desconecta os botoes que foram pressionados na questão atual
	for i in buttonsQuestion:
		i.pressed.disconnect(buttonsAnswer) 
	#espera um tempo determinado para exibir a proxima questão
	await get_tree().create_timer(0.1).timeout
	#altera automaticamente a cor dos botoes para branco
	for i in buttonsQuestion:
		i.modulate = Color.WHITE 
	#muda o indice da questão automaticamente para a proxima
	QuestionIndex +=1
	#chama a função novamente e exibe os novos enunciados
	LoadQuiz()

func ResetQuestionQuiz() -> void:
	#desconecta os botoes 
	for i in buttonsQuestion:
		if i.pressed.is_connected(buttonsAnswer):
			i.pressed.disconnect(buttonsAnswer) 
	#reseta o score, o indice para a primeira posição e randomiza a orden de exibição delas 
	temasQuestoes[ThemeIndex].ThemeQuestion.shuffle()
	QuestionIndex = 0
	score = 0
	
	#altera a cor dos botoes para branco
	for i in buttonsQuestion:
		i.modulate = Color.WHITE 
	#chama a função para exibir os enunciados novamente
	LoadQuiz()
	
func LoadSettings() ->void:
	#ativar e desativar som
	pass
func GameOver() ->void:
	$GameOver.show()
	$GameOver/Label.text = "Parabéns, " + InsertName.text + "\ntotal de acertos"
	$GameOver/Score.text = str(score,"/", QtdQuestions)
	
func _on_menu_screen_pressed() -> void:
	get_tree().reload_current_scene()

func _on_theme_select_screen_pressed() -> void:
	$Select_theme.show()
	$GameOver.hide()
	$StartGame.hide()
	ResetQuestionQuiz()
	$Question_select.hide()
	
	
func _on_play_again_screen_pressed() -> void:
	$Select_theme.hide()
	$GameOver.hide()
	$Question_select.show()
	ResetQuestionQuiz()


func _on_name_text_changed(new_text: String) -> void:

	start_button.disabled = new_text.strip_edges() == ""


func _on_start_button_pressed() -> void:
	
	StartGame()
	
func _on_config_button_pressed() -> void:
	LoadSettings()


func _on_exit_button_pressed() -> void:
	get_tree().quit()
