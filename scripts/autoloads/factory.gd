class_name Factory extends Object

static func create_enemy(enemy_id: Constants.EnemyTypes) -> Enemy:
	var scene_path: String = Constants.ENEMY_SCENE
	var enemy_scene: PackedScene = load(scene_path)
	var new_instance: Enemy = enemy_scene.instantiate()
	new_instance.type = enemy_id
	return new_instance
