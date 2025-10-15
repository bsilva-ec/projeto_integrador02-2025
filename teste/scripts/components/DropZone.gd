# DropZone.gd
extends ColorRect

@export var id: String = ""
@export var tamanho_padrao: Vector2 = Vector2(100, 100)

# Referência para a Area2D de detecção
var area_deteccao: Area2D

func _ready():
	# Configurar tamanho padrão
	custom_minimum_size = tamanho_padrao
	size = tamanho_padrao
	
	# Criar Area2D para detecção de colisão
	area_deteccao = Area2D.new()
	area_deteccao.name = "AreaDeteccao"
	
	# Criar CollisionShape2D
	var forma_colisao = CollisionShape2D.new()
	var retangulo = RectangleShape2D.new()
	retangulo.size = tamanho_padrao
	forma_colisao.shape = retangulo
	
	area_deteccao.add_child(forma_colisao)
	add_child(area_deteccao)
	
	# Visualização (opcional - pode remover depois)
	color = Color(1, 0, 0, 0.3)  # Vermelho semi-transparente para debug

# Método para obter a Area2D de detecção
func obter_area_deteccao() -> Area2D:
	return area_deteccao

# Método para verificar se um ponto está dentro da zona
func ponto_esta_dentro(posicao_global: Vector2) -> bool:
	var rect_global = Rect2(global_position, size)
	return rect_global.has_point(posicao_global)
