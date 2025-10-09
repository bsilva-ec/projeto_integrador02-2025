# DropZone.gd
extends ColorRect

@export var id: String = "" # ID único desta área de drop
# Você pode adicionar propriedades para feedback visual (ex: destacar ao passar o mouse)

func _ready():
	# Isso é apenas um placeholder. A légica de drop é tratada principalmente
	# pelo DraggableItem e pelo DragDropChallenge.
	pass
