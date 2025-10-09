# RelateItem.gd
extends PanelContainer

# Identificador único para este item, vindo dos dados do desafio
var id: String

# Referências para os nós filhos que foi configurado na cena.
@onready var image_display: TextureRect = $VBoxContainer/ImageDisplay
@onready var text_label: Label = $VBoxContainer/TextLabel

func _ready():
	# Conecta os sinais do próprio PanelContainer para dar feedback visual ao jogador.
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	# Cor inicial (totalmente opaco e branco)
	self_modulate = Color(1, 1, 1, 1)

# Define o texto do item. Se o texto for vazio, esconde o Label.
func set_text(new_text: String) -> void:
	text_label.text = new_text
	text_label.visible = not new_text.is_empty()

# Define a imagem do item. Se a textura for nula, esconde o TextureRect
func set_imagem(new_texture: Texture2D) -> void:
	image_display.texture = new_texture
	image_display.visible = (new_texture != null)

# Função de Feedback Visual

# Quando o mouse entra na área do item, ele fica um pouco mais claro.
func _on_mouse_entered():
	self_modulate = Color(1.2, 1.2, 1.2, 1)  # Um branco mais "brilhante"

# Quando o mouse sai, ele volta à cor normal.
func _on_mouse_exited():
	self_modulate = Color(1, 1, 1, 1)
