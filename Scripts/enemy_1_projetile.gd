extends Area2D

@export var speed: float = 400
var direction: Vector2 = Vector2.RIGHT
@export var damage: int = 20
var shooter: Node = null  # <- ESSA LINHA é essencial!

func _process(delta):
	position += direction * speed * delta


func _on_body_entered(body: Node2D) -> void:
	if body == shooter:
		return # ignora o inimigo que disparou
	if body.has_method("take_damage"):
		if body.is_invincible:
			return
		body.take_damage(damage)
		
		
		queue_free()
