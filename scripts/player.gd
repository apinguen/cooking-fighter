extends CharacterBody2D


const SPEED: float = 100.0
const SPRINT_SPEED: float = 300.0
const JUMP_VELOCITY: float = -400.0

var last_dir: float = 1
var sprint: bool = false

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D



func _physics_process(delta: float) -> void:
	process_movement_top()
	play_animation(true)
	move_and_slide()


func process_movement_top() -> void:
	var direction := Input.get_vector("left", "right","up","down")
	sprint = Input.is_action_pressed("sprint")
	
	if (sprint):
		velocity = direction * SPRINT_SPEED
	else:
		velocity = direction * SPEED
		
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
		if (Input.get_vector("left", "right","up","down")):
			if (sprint):
				animated_sprite_2d.play("run_right")
			else:
				animated_sprite_2d.play("walk_right")
		else:
			animated_sprite_2d.play("idle_right")
			
			
