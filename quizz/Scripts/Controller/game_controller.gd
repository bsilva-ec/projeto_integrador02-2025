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
var SongMute: bool = false
var FXSongMute: bool = false
var pauseButtonScreen: bool
var SongInitialMenuChange: bool = true
var quizSelectThemeAgain: bool
#tela das questoes
@onready var question_select: Control = $Question_select
@onready var question_options: VBoxContainer = $Question_select/QuestionOptions
@onready var question_text: Label = $Question_select/QuestionStatement/QuestionText
@onready var texture_rect: TextureRect = $Question_select/QuestionStatement/QuestionImage/TextureRect



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

func HideScreens():
	$StartGame.hide()
	$Question_select.hide()
	$Select_theme.hide()

func _ready() -> void:
	$StartGame/InitialMenuSong.play()
	if SongInitialMenuChange == false:
		$StartGame/InitialMenuSong.volume_db = -80
	else:
		$StartGame/InitialMenuSong.volume_db = 0
		
	$StartGame/Name.text = ""
	start_button.disabled = true
	score = 0
	for buttons in $Question_select.get_children():
		buttonsQuestion.append(buttons)
		
	for buttons in $StartGame/InitialMenuButtons.get_children():
		buttonsMenuInitial.append(buttons)
		
	for buttons in $Select_theme.get_children():
		buttonsThemes.append(buttons)
	$PauseScreen.hide()
	
	StartGame()
	
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
	$StartGame/InitialMenuSong.stop()
	$Select_theme.show()
	$Question_select/QuestionSong.play()
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
			$Select_theme.hide()
			$Question_select.show()
			LoadQuiz()
		1:
			ThemeIndex = 1
			$Select_theme.hide()
			$Question_select.show()
			LoadQuiz()
		2:
			ThemeIndex = 2
			$Select_theme.hide()
			$Question_select.show()
			LoadQuiz()
	#randomiza as questões antes de exibi-las
	temasQuestoes[ThemeIndex].ThemeQuestion.shuffle()
	QuestionIndex = 0
		
func LoadQuiz() ->void:
	pauseButtonScreen = true
	
	if QuestionIndex >= QtdQuestions:
		$GameOver/GameOverSong.play()
		GameOver()
		$Question_select.hide()
		return
	
	#implementação dos enunciados 
	question_text.text = temasQuestoes[ThemeIndex].ThemeQuestion[QuestionIndex].Statement
	#implementação das questões
	for i in buttonsQuestion.size():
		buttonsQuestion[i].text = temasQuestoes[ThemeIndex].ThemeQuestion[QuestionIndex].Options[i]
		buttonsQuestion[i].pressed.connect(buttonsAnswer.bind(buttonsQuestion[i]))
	if temasQuestoes[ThemeIndex].ThemeQuestion[QuestionIndex].QuestionImage != null:
		$Question_select/QuestionStatement/TextureRect.show()
		$Question_select/QuestionStatement/TextureRect.texture = temasQuestoes[ThemeIndex].ThemeQuestion[QuestionIndex].QuestionImage
	else:
		$Question_select/QuestionStatement/TextureRect.hide()
	
func buttonsAnswer(button) ->void:
	#habilita o botao esc para a tela de pause
	pauseButtonScreen = true
	
	print(button.text)
	if temasQuestoes[ThemeIndex].ThemeQuestion[QuestionIndex].correct == button.text:
		button.modulate = color_right
		$Question_select/CorrectQuestion.play()
		score +=1
	else:
		button.modulate = color_wrong
		$Question_select/WrongQuestion.play()
	NextQuestionQuiz()
#função para preparar o quiz para a proxima questão
func NextQuestionQuiz() -> void:
	#desabilita o botao esc na transição de questões
	pauseButtonScreen = false
	#desconecta os botoes que foram pressionados na questão atual
	for i in buttonsQuestion:
		i.pressed.disconnect(buttonsAnswer) 
	#espera um tempo determinado para exibir a proxima questão
	await get_tree().create_timer(1).timeout
	
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
	#inicia o quiz novamente com perguntas aleatorias
	LoadQuiz()
func LoadSettings() ->void:
	$Settings.show()
	$PauseScreen/VBoxContainer/ReturnGame.hide()
	if $PauseScreen/VBoxContainer/MusicOn_Off.modulate == Color.RED:
		SongInitialMenuChange = false
#Exibe a tela de game over, o nome do usuario e a sua pontuação
func GameOver() ->void:
	$GameOver.show()
	$GameOver/Label.text = "Parabéns, " + InsertName.text + "\ntotal de acertos"
	$GameOver/Score.text = str(score,"/", QtdQuestions)
#botao da tela game over para a tela de menu principal
func _on_menu_screen_pressed() -> void:
	get_tree().reload_current_scene()

#botao para a tela de seleção de tema (game over)
func _on_theme_select_screen_pressed() -> void:
	$Select_theme.show()
	$GameOver.hide()
	$StartGame.hide()
	$Question_select.hide()
	ResetQuestionQuiz()	
	
#botao que permite o usuario jogar o mesmo tema novamente (game over)
func _on_play_again_screen_pressed() -> void:
	#esconde a tela de seleção de tema, a tela de game over e exibe a tela do enunciado das questoes
	$Question_select.show()
	$Select_theme.hide()
	$GameOver.hide()												
	ResetQuestionQuiz()
#campo para o usuario inserir o nome (menu principal)
func _on_name_text_changed(new_text: String) -> void:
	start_button.disabled = new_text.strip_edges() == ""
#conectores dos botoes para futuras mudançs ou melhorias no codigo
#botao da tela do menu principal para iniciar o jogo
#func _on_start_button_pressed() -> void:
#	StartGame()
#botao da tela do menu principal para ir para a tela de configurações
#func _on_config_button_pressed() -> void:
#	LoadSettings()
#botao da tela de menu principal para fechar o jogo
#func _on_exit_button_pressed() -> void:
#	get_tree().quit()

#botao para habilitar/desabilitar as musicas (configurações menu inicial)
func _on_song_config_pressed() -> void:
	SongMute = !SongMute
	if SongMute:
		$Settings/VBoxContainer/SongConfig.modulate = Color.RED
		$StartGame/InitialMenuSong.volume_db = -80
		$Question_select/QuestionSong.volume_db = -80
	else:
		$Settings/VBoxContainer/SongConfig.modulate = Color.GREEN
		$StartGame/InitialMenuSong.volume_db = 0
		$Question_select/QuestionSong.volume_db = 0

#botao para habilitar/desabilitar os efeitos sonoros (configurações menu inicial)
func _on_audio_fx_config_pressed() -> void:
	FXSongMute = !FXSongMute
	if FXSongMute:
		$Settings/VBoxContainer/AudioFXConfig.modulate = Color.RED
		$Question_select/WrongQuestion.volume_db = -80
		$Question_select/CorrectQuestion.volume_db = -80
	else:
		$Settings/VBoxContainer/AudioFXConfig.modulate = Color.GREEN
		$Question_select/WrongQuestion.volume_db = 0
		$Question_select/CorrectQuestion.volume_db = 0

#botao para voltar para a tela de menu inicial (configurações menu inicial)
func _on_quit_pressed() -> void:
	$Settings.hide()
	$StartGame.show()
#botao para habilitar/desabilitar as musicas (tela pause)
func _on_music_on_off_pressed() -> void:
	SongMute = !SongMute
	if SongMute:
		$PauseScreen/VBoxContainer/MusicOn_Off.modulate = Color.RED
		$StartGame/InitialMenuSong.volume_db = -80
		$Question_select/QuestionSong.volume_db = -80
	else:
		$PauseScreen/VBoxContainer/MusicOn_Off.modulate = Color.GREEN
		$StartGame/InitialMenuSong.volume_db = 0
		$Question_select/QuestionSong.volume_db = 0
		
#botao para habilitar/desabilitar os efeitos sonoros (tela pause)
func _on_audio_fx_on_off_pressed() -> void:
	FXSongMute = !FXSongMute
	if FXSongMute:
		$PauseScreen/VBoxContainer/AudioFXOn_Off.modulate = Color.RED
		$Question_select/WrongQuestion.volume_db = -80
		$Question_select/CorrectQuestion.volume_db = -80
	else:
		$PauseScreen/VBoxContainer/AudioFXOn_Off.modulate = Color.GREEN
		$Question_select/WrongQuestion.volume_db = 0
		$Question_select/CorrectQuestion.volume_db = 0
		
#botao para retornar ao jogo (tela pause)
func _on_return_game_pressed() -> void:
	#esconde a tela de pause
	$PauseScreen.hide()
	#exibe novamente a tela de questões
	$Question_select.show()

#botao para voltar ao menu principal (tela pause)
func _on_return_pressed() -> void:
	get_tree().reload_current_scene()
	
#implementação do esc para tela de pause
func _input(event: InputEvent) -> void: 
	if event.is_action_pressed("ui_cancel"): 
		#se pauseButtonScreen for falso, ele interrompe a função nao permitindo que 
		#o botao esc vá para a tela de pause.
		#o pauseButtonScreen é falso no inicio da função NextQuestionQuiz(), ou seja,
		#ao executar essa função, o botao esc fica desabilitado.
		if not pauseButtonScreen:
			return
		#se a tela de questoes estiver visivel, ela exibe a tela de pause e 
		#oculta a tela de questoes ao clicar no esc
		if$Question_select.visible:
			$PauseScreen.show()
			$Question_select.hide()
		#se a tela de pause estiver visivel, a função oculta a tela de pause
		#e exibe a tela de questoes ao clicar no esc
		elif$PauseScreen.visible:
			$PauseScreen.hide()
			$Question_select.show()
		
	
