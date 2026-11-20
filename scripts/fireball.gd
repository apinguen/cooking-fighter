class_name Fireball
extends CharacterBody2D
var pos:Vector2
var rota:float
var dir:float
var speed:float = 200
var reflected = false

const L_PLAYER := 2
const L_ENEMY := 3
const L_ENEMY_PROJ := 4
const L_PLAYER_PROJ := 5

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $FireballHitbox

func _ready():
	global_position = pos
	global_rotation = rota
	animated_sprite_2d.play("start")
	
	await get_tree().create_timer(10.0).timeout
	queue_free()
	
func _physics_process(delta: float) -> void:
	velocity = Vector2(speed, 0).rotated(dir)
	move_and_slide()
	
func reflect():
	dir += PI
	rotation = dir
	reflected = true
	
	#set_collision_layer_value(L_ENEMY_PROJ, false)
	#set_collision_layer_value(L_PLAYER_PROJ, true)
	#set_collision_mask_value(L_PLAYER, false)
	#set_collision_mask_value(L_ENEMY, true)
	
	hitbox.set_collision_layer_value(L_ENEMY_PROJ, false)
	hitbox.set_collision_layer_value(L_PLAYER_PROJ, true)
	hitbox.set_collision_mask_value(L_PLAYER, false)
	hitbox.set_collision_mask_value(L_ENEMY, true)
	
func has_been_reflected() -> bool:
	return reflected


func _on_animated_sprite_2d_animation_finished() -> void:
	animated_sprite_2d.play("fly")
	





func _on_hitbox_area_entered(area: Area2D) -> void:
	#print(area.name)
	if (area.name == "ShieldHitbox" || area.name == "FireballHitbox"):
		return
	if (area.get_parent().has_method("take_damage")):
		area.get_parent().take_damage(1)
	queue_free()
