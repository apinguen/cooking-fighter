extends CharacterBody2D


const SPEED: float = 300.0
const SPRINT_SPEED: float = 600.0
const JUMP_VELOCITY: float = -50000.0
const ACCEL: float = 1500
const GRAVITY_SCALAR: float = 50

var input: Vector2 = Vector2(0,0)

var last_dir: float = 1
var sprint: bool = false

enum PlayerStates {
	IDLE,
	MOVE,
	ATTACK,
	SHIELD,
}

enum MovementStyles {
	TOP,
	SIDE,
}

enum ShieldStates {
	HIDDEN,
	DEPLOY,
	IDLE,
	HIT,
	POP,
}

@export var state: PlayerStates = PlayerStates.IDLE
var movement_style: MovementStyles = MovementStyles.SIDE
var shield_state: ShieldStates = ShieldStates.HIDDEN

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var shield_sprite: AnimatedSprite2D = $Shield
@onready var camera_2d: Camera2D = $Camera2D



func _physics_process(delta: float) -> void:
	if (movement_style == MovementStyles.TOP):
		camera_2d.limit_enabled = true
	else:
		camera_2d.limit_enabled = false
		
	process_input()
	if (movement_style == MovementStyles.TOP):
		process_movement_top(delta)
	else:
		process_movement_side(delta)
		
	play_animation()
	move_and_slide()
	#print(PlayerStates.keys()[state])

func process_input():
	input = Input.get_vector("left", "right","up","down")
	if (input.length() > 1.0):
		input = input.normalized()
		
	if (movement_style == MovementStyles.SIDE):
		if (state == PlayerStates.IDLE || state == PlayerStates.MOVE):
			if (Input.is_action_just_pressed("attack")):
				state = PlayerStates.ATTACK
				animated_sprite_2d.play("attack_right")
				return
		
		if (state != PlayerStates.SHIELD):
			if (Input.is_action_just_pressed("shield")):
				shield_sprite.visible = true
				state = PlayerStates.SHIELD
				shield_state = ShieldStates.DEPLOY
				shield_sprite.play("deploy")
				return
		else:
			if (Input.is_action_just_released("shield")):
				shield_state = ShieldStates.POP
				shield_sprite.play("pop")
			
	
	if (state != PlayerStates.ATTACK && state != PlayerStates.SHIELD):
		if (input):
			state = PlayerStates.MOVE
		else:
			state = PlayerStates.IDLE

func process_movement_top(delta: float) -> void:
	sprint = Input.is_action_pressed("sprint")
	
	if (state == PlayerStates.MOVE):
		if (sprint):
			velocity.x = move_toward(velocity.x, input.x * SPRINT_SPEED, ACCEL * delta)
		else:
			velocity.x = move_toward(velocity.x, input.x * SPEED, ACCEL * delta)
	else:
		velocity.x = move_toward(0, input.x * SPEED, ACCEL * delta)
	
	if (Input.get_axis("left", "right")):
		last_dir = Input.get_axis("left", "right")
		

func process_movement_side(delta: float) -> void:
	sprint = Input.is_action_pressed("sprint")
	var velocity_y: float = 0
	var velocity_x: float = 0
	if !is_on_floor():
		velocity_y += get_gravity().y * delta * GRAVITY_SCALAR
	
	if (state == PlayerStates.MOVE):
			
		if Input.is_action_just_pressed("up") && is_on_floor():
			velocity_y = JUMP_VELOCITY
			print("Jump")
		
		if (sprint):
			velocity_x = input.x * SPRINT_SPEED
		else:
			velocity_x = input.x * SPEED
		velocity = velocity.move_toward(Vector2(velocity_x, velocity_y), ACCEL * delta)
		velocity.y = velocity_y
	else:
		velocity = velocity.move_toward(Vector2(0, velocity_y), ACCEL * delta)
		velocity.y = velocity_y
		
	if (Input.get_axis("left", "right")):
		last_dir = Input.get_axis("left", "right")


func play_animation() -> void:
	animated_sprite_2d.flip_h = last_dir < 0
	if (state == PlayerStates.MOVE):
		if (sprint):
			animated_sprite_2d.play("run_right")
		else:
			animated_sprite_2d.play("walk_right")
	else:
		animated_sprite_2d.play("idle_right")
	
			
func transition_to_mode(mode: MovementStyles):
	velocity = Vector2.ZERO
	movement_style = mode


func _on_animated_sprite_2d_animation_finished() -> void:
	if (state == PlayerStates.ATTACK):
		state = PlayerStates.IDLE
	

func _on_shield_animation_finished() -> void:
	match shield_state:
		ShieldStates.DEPLOY:
			shield_state = ShieldStates.IDLE
			shield_sprite.play("idle")
		ShieldStates.POP:
			shield_state = ShieldStates.HIDDEN
			state = PlayerStates.IDLE
