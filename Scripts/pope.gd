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


#Ranged attack
@export var projetile_scene : PackedScene;
@export var damage_ranged : int = 10;


#Dash
@export var dash_speed: float = 600.0
@export var dash_duration: float = 0.2
@export var dash_cooldown: float = 0.5
var dash_direction: int = 1
var is_dashing: bool = false
var dash_time: float = 0.0
var dash_cd_time: float = 0.0



func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		
	if is_dashing:
		dash_time -= delta
		if dash_time > 0:
			velocity.x = dash_direction * dash_speed
		else:
			end_dash()
	else:
		#Handle normal walk
		var direction = Input.get_axis("ui_left", "ui_right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		# Handle jump.
		if Input.is_action_just_pressed("ui_up") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		#Handle Dash
		if dash_cd_time > 0:
			dash_cd_time -= delta
		if Input.is_action_just_pressed("ui_dash") and dash_cd_time <= 0:
			start_dash()

	move_and_slide()
	
	# Melee attack
	if Input.is_action_just_pressed("ui_melee"):
		attack_melee();
	
		
	# Ranged attack
	if Input.is_action_just_pressed("ui_ranged"):
		attack_ranged();
	
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
	
	if combo_step == 0:
		damage = damage_melee1
	elif combo_step == 1:
		damage = damage_melee2
	elif combo_step == 2:
		damage = damage_melee3
	
	for body in hitbox_melee.get_overlapping_bodies():
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

	# Optional: imune during dash?

func end_dash() -> void:
	print("Dash ended")
	is_dashing = false
