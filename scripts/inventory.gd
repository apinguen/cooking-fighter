class_name Inventory
extends Resource

signal inventory_changed

var items: Dictionary = {}

func add(item: FoodData, amount: int = 1) -> void:
	items[item] = get_count(item) + amount
	inventory_changed.emit()
	
func remove(item: FoodData, amount: int = 1) -> bool:
	if (get_count(item) < amount):
		return false
	items[item] -= amount
	if items[item] <= 0:
		items.erase(item)
	inventory_changed.emit()
	return true
	
func get_count(item: FoodData) -> int:
	return items.get(item, 0)
