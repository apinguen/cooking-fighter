extends CharacterBody2D


const SPEED: float = 300.0
const SPRINT_SPEED: float = 600.0
const JUMP_VELOCITY: float = -400.0
const ACCEL: float = 1500

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

var state: PlayerStates = PlayerStates.IDLE
var movemen_style: MovementStyles = MovementStyles.TOP
var shield_state: ShieldStates = ShieldStates.HIDDEN

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var shield_sprite: AnimatedSprite2D = $Shield



func _physics_process(delta: float) -> void:
	process_input()
	process_movement_top(delta)
	play_animation(true)
	move_and_slide()
	#print(PlayerStates.keys()[state])

func process_input():
	input = Input.get_vector("left", "right","up","down")
	if (input.length() > 1.0):
		input = input.normalized()
		
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
			velocity = velocity.move_toward(input * SPRINT_SPEED, ACCEL * delta)
		else:
			velocity = velocity.move_toward(input * SPEED, ACCEL * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, ACCEL * delta)
	
	if (Input.get_axis("left", "right")):
		last_dir = Input.get_axis("left", "right")
		

func process_movement_side(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump
	if Input.is_action_just_pressed("up") and is_on_floor():
		velocity.y = JUMP_VELOCITY


func play_animation(top_mode: bool) -> void:
	if (top_mode):
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
