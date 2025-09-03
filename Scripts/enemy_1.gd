extends CharacterBody2D


@export var health: int = 60;
@export var max_health: int = 60;

@onready var health_bar: ProgressBar = $Health_bar;
@onready var label_finisher: Label = $Label_finisher;

var can_be_executed : bool = false;


#Enemy projetile
@export var projectile_scene: PackedScene
@export var projectile_speed: float = 400.0
@export var projectile_damage: int = 20
@export var fire_rate: float = 4.0 # tempo entre disparos em segundos

var fire_timer: float = 0.0
var player_ref: Node = null

func _ready():
	health_bar.max_value = max_health;
	health_bar.value = health;
	label_finisher.visible = false;
	
	# References the player so it can track it
	player_ref = get_tree().get_current_scene().get_node("Pope")

func _process(delta: float) -> void:
	if player_ref:
		fire_timer -= delta
		if fire_timer <= 0:
			fire_projectile()
			fire_timer = fire_rate
			
			
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
	
	
func fire_projectile() -> void:
	if not projectile_scene or not player_ref:
		return

	var proj = projectile_scene.instantiate()
	get_parent().add_child(proj)
	proj.global_position = global_position

	# Direção horizontal para o player
	var dir = Vector2.RIGHT
	if player_ref.global_position.x < global_position.x:
		dir = Vector2.LEFT

	proj.direction = dir
	proj.speed = projectile_speed
	proj.damage = projectile_damage
	proj.shooter = self
	
