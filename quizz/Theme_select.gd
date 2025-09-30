extends Node

class_name  theme_Select

@export var All_Themes: Array[Question] = []

var SelectedThemes: Question = null

@onready var theme_buttons = {
	"tema 1":$Select_theme/VBoxContainer/Tema1,
	"tema 2":$Select_theme/VBoxContainer/Tema2,
}
@onready var start_button: Button = $StartGame/StartButton

func _on_start_button_pressed():
	if SelectedThemes:
		var quiz_controller = preload("res://Scenes/Main.tscn").instantiate()
		quiz_controller.quiz = SelectedThemes
		
		get_tree().root.add_child(quiz_controller)
		get_tree().current_scene = quiz_controller
		queue_free()  # Remove a tela de seleção

func _on_theme_button_pressed(themeName: String):
	for theme in All_Themes:
		if theme.themeName == themeName:
			SelectedThemes = theme
			break
	for button_name in theme_buttons:
		var button = theme_buttons[button_name]
		if button_name == themeName:
			button.modulate = Color.GREEN 
		else:
			button.modulate = Color.WHITE
	

func  _ready() -> void:
	for themeName in theme_buttons:
		var button = theme_buttons[themeName]
		button.pressed.connect(_on_theme_button_pressed.bind(themeName))
	start_button.pressed.connect(_on_start_button_pressed)
