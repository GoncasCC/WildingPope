extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0



# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


#Melee atack
@export var damage_melee1 : int = 15;
@export var damage_melee2 : int = 15;
@export var damage_melee3 : int = 20;
var combo_step: int = 0
var combo_timer: float = 0.0
const COMBO_MAX_TIME = 0.5 # max time between combo attacks
@onready var hitbox_melee : Area2D = $HitboxMelee;
var is_attacking: bool = false
var attack_timer: float = 0.0
const ATTACK_DURATION: float = 0.3 # duração da animação do melee em segundos


#Ranged attack
@export var projetile_scene : PackedScene;
@export var damage_ranged : int = 10;
var is_shooting: bool = false
var shooting_timer: float = 0.0
const SHOOTING_DURATION: float = 0.3 # duração da animação do melee em segundos


#Dash
@export var dash_speed: float = 800.0
@export var dash_duration: float = 0.3
@export var dash_cooldown: float = 0.5
var dash_direction: int = 1
var is_dashing: bool = false
var dash_time: float = 0.0
var dash_cd_time: float = 0.0
var is_invincible: bool = false


#Health
@export var max_health: int = 100
var health: int = 100

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D



func _physics_process(delta):
	var direction = Input.get_axis("ui_left", "ui_right") 
	
	if direction > 0:
		sprite.flip_h = false
	elif direction <0:
		sprite.flip_h = true
		

	if is_dashing:
		velocity.x = dash_direction * dash_speed
		dash_time -= delta
		if dash_time <= 0:
			end_dash()
	else:
		# Horizontal movement
		if direction != 0:
			velocity.x = direction * SPEED
		else:
			velocity.x = lerp(velocity.x, 0.0, 0.2)

	velocity.y += gravity * delta

	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if dash_cd_time > 0:
		dash_cd_time -= delta
	if Input.is_action_just_pressed("ui_dash") and dash_cd_time <= 0:
		start_dash()
		# Update attack timer
	if is_attacking:
		attack_timer -= delta
		if attack_timer <= 0:
			is_attacking = false
	if is_shooting:
		shooting_timer -= delta
		if shooting_timer <= 0:
			is_shooting = false

	move_and_slide()
	
	# Melee attack
	if Input.is_action_just_pressed("ui_melee"):
		attack_melee()
	# Ranged attack
	if Input.is_action_just_pressed("ui_ranged"):
		attack_ranged();
	
	if is_attacking:
		sprite.play("melee")
	elif is_shooting:
		sprite.play("shooting")
	elif is_dashing:
		sprite.play("dash")
	else:
		if is_on_floor():
			if direction == 0:
				sprite.play("iddle")
			else:
				sprite.play("run")	
		else:
			sprite.play("jump")
	
	# reset combo if too much time has passed
	if combo_timer > 0:
		combo_timer -= delta
		if combo_timer <= 0:
			combo_step = 0
			
	if Input.is_action_just_pressed("ui_execute"):
		for body in hitbox_melee.get_overlapping_bodies():
			if body.has_method("execute") and body.can_be_executed:
				body.execute()
	
	
#Melee method
func attack_melee() -> void:
	var damage = 0;
	is_attacking = true
	attack_timer = ATTACK_DURATION
	
	if combo_step == 0:
		damage = damage_melee1
	elif combo_step == 1:
		damage = damage_melee2
	elif combo_step == 2:
		damage = damage_melee3
	
	for body in hitbox_melee.get_overlapping_bodies():
		if body == self:
			continue 
		if body.has_method("take_damage"):
			body.take_damage(damage);
	
	# Advances combo
	combo_step += 1
	if combo_step > 2:
		combo_step = 0 # after third hit goes back to beggining
	
	# Combo timer
	combo_timer = COMBO_MAX_TIME

			
#Ranged method
func attack_ranged():
	var proj = projetile_scene.instantiate();
	get_parent().add_child(proj);
	
	is_shooting = true
	shooting_timer = SHOOTING_DURATION
	
	#Define projetile direction
	var dir = Vector2.RIGHT;
	if velocity.x < 0:
		dir = Vector2.LEFT;
	proj.direction = dir;
	
	proj.global_position = global_position + (dir * 80);
	
		
	proj.damage = damage_ranged;
	
#Dash methods
func start_dash() -> void:
	print("Dash started");
	is_dashing = true
	dash_time = dash_duration
	dash_cd_time = dash_cooldown

	# Decides direction of the dash
	dash_direction = sign(velocity.x)
	if dash_direction == 0:
		dash_direction = 1

	is_invincible = true

func end_dash() -> void:
	print("Dash ended")
	is_dashing = false
	is_invincible = false
	
	
	
#Health methods
func take_damage(damage: int):
	health -= damage
	health = max(0, health)
	print("Player took ", damage, " damage. Remaining health: ", health)

	if health <= 0:
		die()

func heal(amount: int):
	health += amount
	health = min(max_health, health)

func die():
	print("Player died")
	# aqui podes fazer respawn ou game over
