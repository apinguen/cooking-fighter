class_name FoodPickup
extends Area2D

@export var data: FoodData

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	if data:
		sprite.texture = data.icon
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		Game.inventory.add(data)
		queue_free()
		
