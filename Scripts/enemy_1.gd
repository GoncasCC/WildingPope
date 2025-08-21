extends CharacterBody2D


@export var health: int = 40;
@export var max_health: int = 40;

@onready var health_bar: ProgressBar = $Health_bar;

func _ready():
	health_bar.max_value = max_health;
	health_bar.value = health;

func take_damage(damage: int) -> void:
	health -= damage
	print("Enemy has taken ", damage, " damage. Remaining health: ", health)
	health_bar.value = health;
	if health <= 0:
		die()

func die() -> void:
	queue_free() # removes enemy from scene

