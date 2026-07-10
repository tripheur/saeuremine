class_name UpgradePopup
extends Window

@export var list_container: VBoxContainer

var game: Game

func setup(g: Game) -> void:
	game = g
	rebuild_list()

func rebuild_list() -> void:
	for child in list_container.get_children():
		child.queue_free()

	for id in game.upgrades.upgrade_defs.keys():
		var def: Dictionary = game.upgrades.upgrade_defs[id]
		var level: int = game.upgrades.upgrade_levels[id]
		var cost: int = game.upgrades.get_upgrade_cost(id)
		var maxed_out = def.has("max_level") and level >= def.max_level

		var entry = VBoxContainer.new()

		var title_row = HBoxContainer.new()

		var name_label = Label.new()
		name_label.text = "%s (Stufe %s)" % [def.name, level]
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		title_row.add_child(name_label)

		var buy_button = Button.new()
		buy_button.text = "Maximal" if maxed_out else "Kaufen (%s €)" % game.format_number(cost)
		buy_button.disabled = maxed_out or not game.upgrades.can_buy_upgrade(id)
		buy_button.pressed.connect(_on_buy_pressed.bind(id))
		title_row.add_child(buy_button)
		entry.add_child(title_row)

		var desc_label = Label.new()
		desc_label.text = "%s (Karma %s)" % [def.desc, def.get("karma", -5)]
		desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
		entry.add_child(desc_label)

		list_container.add_child(entry)
		list_container.add_child(HSeparator.new())

func _on_buy_pressed(id: String) -> void:
	game.upgrades.buy_upgrade(id)
	rebuild_list()

func _on_close_requested() -> void:
	queue_free()
