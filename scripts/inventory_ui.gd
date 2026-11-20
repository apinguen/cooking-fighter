extends CanvasLayer

@onready var panel: Panel = $Panel
@onready var list: VBoxContainer = $Panel/VBoxContainer

func _ready() -> void:
	panel.hide()
	Game.inventory.inventory_changed.connect(_refresh)
	_refresh()
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_inventory"):
		panel.visible = ! panel.visible
		get_viewport().set_input_as_handled()
		
func _refresh() -> void:
	for child in list.get_children():
		child.queue_free()
	for item: FoodData in Game.inventory.items:
		var label := Label.new()
		label.text = "%s x %d" % [item.display_name, Game.inventory.get_count(item)]
		list.add_child(label)
