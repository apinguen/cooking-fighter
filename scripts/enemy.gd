class_name Enemy
extends CharacterBody2D

const PATROL_SPEED: float = 50.0
const JUMP_VELOCITY: float = -600

const BREAD_SHOT_COOLDOWN: float = 1
const BREAD_SHOT_BURST_TIMING: float = 0.1
const BREAD_SHOT_BURST_COUNT: int = 3

enum MovementTypes {
	STATIC,
	PATROL,
	STATIC_AND_CHASE,
	PATROL_FREEZE,
}

enum EnemyStates {
	IDLE,
	WALK,
	ATTACK_CHARGE,
	ATTACK,
	DYING,
	DEAD,
}

@export var movement_type: MovementTypes = MovementTypes.PATROL_FREEZE
@export var health: int = 1
@export var drops: Array[FoodData]

var state: EnemyStates = EnemyStates.IDLE

var direction: float = 1
var shots_fired: float = 0
var target: Node2D


@onready var bread_sprite: AnimatedSprite2D = $BreadSprite
@onready var tomato_sprite: AnimatedSprite2D = $TomatoSprite
@onready var donut_sprite: AnimatedSprite2D = $DonutSprite
@onready var carrot_sprite: AnimatedSprite2D = $CarrotSprite
@onready var burger_sprite: AnimatedSprite2D = $BurgerSprite
var sprites = []

@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var ray_cast_right: RayCast2D = $RayCastRight

@onready var attack_timer: Timer = $AttackTimer
@onready var shot_timer: Timer = $ShotTimer

var fireball_path := preload("res://scenes/fireball.tscn")
var pickup_path := preload("res://scenes/food_pickup.tscn")

var type: Constants.EnemyTypes = Constants.EnemyTypes.BREAD

func _ready() -> void:
	sprites = [bread_sprite, tomato_sprite, donut_sprite, carrot_sprite, burger_sprite]
	for sprite in sprites:
		sprite.hide()
	
	sprites[state].show()
	
	match movement_type:
		MovementTypes.PATROL, MovementTypes.PATROL_FREEZE:
			state = EnemyStates.WALK
		MovementTypes.STATIC:
			state = EnemyStates.IDLE
	

func _physics_process(delta: float) -> void:
	movement(delta)
	attack()
	animate()
	move_and_slide()

func movement(delta: float) -> void:
	if (!is_on_floor()):
		velocity.y += get_gravity().y * delta
		
		
	match movement_type:
		MovementTypes.PATROL, MovementTypes.PATROL_FREEZE:
			if (state == EnemyStates.WALK):
				if (!ray_cast_left.is_colliding()):
					direction = 1
				elif (!ray_cast_right.is_colliding()):
					direction = -1
				velocity.x = PATROL_SPEED * direction
			else:
				velocity.x = 0
		
func animate():
	
	match type:
		Constants.EnemyTypes.BREAD:
			bread_sprite.flip_h = direction < 0
			match state:
				EnemyStates.IDLE:
					bread_sprite.play("idle_right")
				EnemyStates.WALK:
					bread_sprite.play("walk_right")
				_:
					bread_sprite.play("idle_right")
		Constants.EnemyTypes.TOMATO:
			tomato_sprite.flip_h = direction > 0
			match state:
				EnemyStates.IDLE:
					tomato_sprite.play("idle_left")
					
func attack() -> void:
	if (state != EnemyStates.ATTACK):
		return
	
	match type:
		Constants.EnemyTypes.BREAD:
			if (shot_timer.is_stopped() && attack_timer.is_stopped()):
				attack_timer.start(BREAD_SHOT_COOLDOWN)
				
			
			
func fire_fireball():
	var fireball = fireball_path.instantiate()
	fireball.dir = ((target.global_position - Vector2(0,16)) - global_position).angle()
	fireball.pos = global_position - Vector2(0,16)
	fireball.rota = fireball.dir
	get_tree().current_scene.add_child(fireball)
	
func take_damage(amount: int = 1) -> void:
	health -= amount
	if (health <= 0):
		die()
		
func die() -> void:
	if !drops.is_empty():
		var pickup := pickup_path.instantiate() as FoodPickup
		pickup.data = drops.pick_random()
		pickup.global_position = global_position - Vector2(0, 32)
		get_tree().current_scene.add_child.call_deferred(pickup)
	queue_free()

func _on_tomato_sprite_animation_finished() -> void:
	if (type == Constants.EnemyTypes.TOMATO):
		if (state == EnemyStates.ATTACK_CHARGE):
			tomato_sprite.play("attack_final_left")
			state = EnemyStates.ATTACK


func _on_aggro_area_shoot_area_entered(area: Area2D) -> void:
	if (area.get_parent() is Player):
		target = area.get_parent()
		if (movement_type == MovementTypes.PATROL_FREEZE):
			if (type == Constants.EnemyTypes.BREAD):
				if (state != EnemyStates.ATTACK):
					state = EnemyStates.ATTACK
					attack_timer.start(BREAD_SHOT_COOLDOWN)
		


func _on_aggro_area_melee_area_entered(area: Area2D) -> void:
	if (area.get_parent() is Player):
		target = area.get_parent()
		if (movement_type == MovementTypes.PATROL_FREEZE):
			if (type == Constants.EnemyTypes.TOMATO):
				if (state != EnemyStates.ATTACK && state != EnemyStates.ATTACK_CHARGE):
					state = EnemyStates.ATTACK_CHARGE


func _on_aggro_area_melee_area_exited(area: Area2D) -> void:
	if (area.get_parent() is Player):
		if (movement_type == MovementTypes.PATROL_FREEZE):
			if (type == Constants.EnemyTypes.TOMATO):
				if (state == EnemyStates.ATTACK_CHARGE || state == EnemyStates.ATTACK):
					state = EnemyStates.WALK


func _on_aggro_area_shoot_area_exited(area: Area2D) -> void:
	if (area.get_parent() is Player):
		if (movement_type == MovementTypes.PATROL_FREEZE):
			if (type == Constants.EnemyTypes.BREAD):
				if (state == EnemyStates.ATTACK_CHARGE || state == EnemyStates.ATTACK):
					state = EnemyStates.WALK


func _on_attack_timer_timeout() -> void:
	attack_timer.stop()
	if (state != EnemyStates.ATTACK):
		return
		
	fire_fireball()
	shots_fired = 1
	shot_timer.start(BREAD_SHOT_BURST_TIMING)


func _on_shot_timer_timeout() -> void:
	shot_timer.stop()
	if (state != EnemyStates.ATTACK):
		return
		
	if (shots_fired == BREAD_SHOT_BURST_COUNT):
		return
		
	fire_fireball()
	shots_fired += 1
	if (shots_fired == BREAD_SHOT_BURST_COUNT):
		attack_timer.start(BREAD_SHOT_COOLDOWN)
	else:
		shot_timer.start(BREAD_SHOT_BURST_TIMING)
