extends CharacterBody2D


@export var health: int = 60;
@export var max_health: int = 60;

@onready var health_bar: ProgressBar = $Health_bar;
@onready var label_finisher: Label = $Label_finisher;

var can_be_executed : bool = false;

func _ready():
	health_bar.max_value = max_health;
	health_bar.value = health;
	label_finisher.visible = false;

func take_damage(damage: int) -> void:
	health -= damage
	print("Enemy has taken ", damage, " damage. Remaining health: ", health)
	health_bar.value = health;
	
	if health <= 10 and health > 0:
		can_be_executed = true
		label_finisher.visible = true
	if health <= 0:
		die()

func execute():
	print("Enemy executed")
	die()
	
	
func die() -> void:
	queue_free() # removes enemy from scene

