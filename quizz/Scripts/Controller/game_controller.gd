extends Node

var quiz: themes
@export var color_right: Color
@export var color_wrong: Color

var buttons: Array[Button]
var index: int
var correct: int

@onready var questionText: Label = $Control/VBoxContainer/Label

func _ready() -> void:
	for button in $Control/Option.get_children():
		buttons.append(button)
		
		
		
func load_quiz() ->void:
	pass
