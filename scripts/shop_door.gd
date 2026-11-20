extends Area2D


func _on_body_entered(body: Node2D) -> void:
	print(body.name)
	SceneLoader.load_scene("uid://cyy7fm4arcs8p")
