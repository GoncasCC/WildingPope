extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0



# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


@export var damage_melee : int = 20;
@onready var hitbox_melee : Area2D = $HitboxMelee;

@export var projetile_scene : PackedScene;
@export var damage_ranged : int = 10;


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
	# Melee attack
	if Input.is_action_just_pressed("ui_melee"):
		attack_melee();
		
	# Ranged attack
	if Input.is_action_just_pressed("ui_ranged"):
		attack_ranged();
		
		
		
func attack_melee() -> void:
	for body in hitbox_melee.get_overlapping_bodies():
		if body.has_method("take_damage"):
			body.take_damage(damage_melee);
			
func attack_ranged():
	var proj = projetile_scene.instantiate();
	get_parent().add_child(proj);
	
	#Define projetile direction
	var dir = Vector2.RIGHT;
	if velocity.x < 0:
		dir = Vector2.LEFT;
	proj.direction = dir;
	
	proj.global_position = global_position + (dir * 80);
	
		
	proj.damage = damage_ranged;
