# RelateItem.gd
extends PanelContainer

var id: String

var display_imagem: TextureRect
var label_texto: Label

func _ready():
	display_imagem = find_child("ImageDisplay", true, false)
	label_texto = find_child("TextLabel", true, false)
	
	mouse_entered.connect(_on_mouse_entrou)
	mouse_exited.connect(_on_mouse_saiu)
	
	self_modulate = Color(1, 1, 1, 1)

func definir_texto(novo_texto: String) -> void:
	label_texto.text = novo_texto
	label_texto.visible = not novo_texto.is_empty()

func definir_imagem(nova_textura: Texture2D) -> void:
	display_imagem.texture = nova_textura
	display_imagem.visible = (nova_textura != null)

func _on_mouse_entrou():
	self_modulate = Color(1.2, 1.2, 1.2, 1)

func _on_mouse_saiu():
	self_modulate = Color(1, 1, 1, 1)
