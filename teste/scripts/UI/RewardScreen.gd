# RewardScreen.gd
extends Control

@onready var label_titulo: Label = $Background/MarginContainer/VBoxContainer/TitleLabel
@onready var label_pontuacao: Label = $Background/MarginContainer/VBoxContainer/ScoreLabel
@onready var label_mensagem: Label = $Background/MarginContainer/VBoxContainer/MessageLabel
@onready var container_estrelas: HBoxContainer = $Background/MarginContainer/VBoxContainer/EstrelasContainer/ContainerEstrelas
@onready var botao_continuar: Button = $Background/MarginContainer/VBoxContainer/ContinueButton

var estrelas: Array = []

func _ready():
	print("RewardScreen carregada!")
	
	# Coletar estrelas
	for i in range(container_estrelas.get_child_count()):
		var estrela = container_estrelas.get_child(i)
		if estrela is TextureRect:
			estrelas.append(estrela)
			estrela.modulate = Color(0.3, 0.3, 0.3)  # Estrelas apagadas
	
	print("   - Estrelas encontradas: ", estrelas.size())

func mostrar_resultado(sucesso: bool, pontuacao: int, dados: Dictionary):
	print("Configurando RewardScreen:")
	print("   - Sucesso: ", sucesso)
	print("   - Pontuação: ", pontuacao)
	print("   - Dados: ", dados)
	
	if sucesso:
		label_titulo.text = "Parabéns!"
		label_titulo.modulate = Color.GOLD
		label_mensagem.text = "Você completou o desafio!"
	else:
		label_titulo.text = "Continue Tentando!"
		label_titulo.modulate = Color.ORANGE_RED
		label_mensagem.text = "Não desista, você consegue!"
	
	label_pontuacao.text = "Pontuação: " + str(pontuacao)
	
	# Calcular estrelas
	calcular_estrelas(pontuacao, dados)
	
	# Animação de entrada
	animar_entrada()

func calcular_estrelas(pontuacao: int, dados: Dictionary):
	var total_perguntas = dados.get("total_perguntas", 1)
	var acertos = dados.get("acertos", 0)
	var precisao = float(acertos) / total_perguntas if total_perguntas > 0 else 0
	
	print("   - Precisão: ", int(precisao * 100), "%")
	print("   - Acertos: ", acertos, "/", total_perguntas)
	
	var estrelas_conquistadas = 0
	if precisao >= 0.9:      # 90% ou mais - 3 estrelas
		estrelas_conquistadas = 3
	elif precisao >= 0.7:    # 70% ou mais - 2 estrelas  
		estrelas_conquistadas = 2
	elif precisao >= 0.5:    # 50% ou mais - 1 estrela
		estrelas_conquistadas = 1
	
	print("   - Estrelas conquistadas: ", estrelas_conquistadas)
	
	# Acender estrelas
	for i in range(estrelas.size()):
		if i < estrelas_conquistadas:
			estrelas[i].modulate = Color.GOLD
		else:
			estrelas[i].modulate = Color(0.3, 0.3, 0.3)

func animar_entrada():
	print("Iniciando animação de entrada...")
	
	# Estado inicial (invisível)
	modulate = Color(1, 1, 1, 0)
	scale = Vector2(0.5, 0.5)
	
	# Animação de entrada
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.8)
	tween.tween_property(self, "scale", Vector2(1, 1), 0.8).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	print("Animação concluída")

func _on_botao_continuar_pressionado():
	print("Botão Continuar pressionado")
	
	# Animação de saída
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.4)
	tween.tween_property(self, "scale", Vector2(0.5, 0.5), 0.4)
	
	await tween.finished
	queue_free()
	print("RewardScreen removida")

func _input(event):
	# Permitir fechar com ESC ou Enter
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
		_on_botao_continuar_pressionado()
