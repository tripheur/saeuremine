class_name RecruitPopup
extends Window

@export var list_container: VBoxContainer

var game: Game

func setup(g: Game) -> void:
	game = g
	rebuild_list()

func rebuild_list() -> void:
	for child in list_container.get_children():
		child.queue_free()

	if game.family_pool.is_empty():
		queue_free()
		return

	for worker in game.family_pool:
		var row = HBoxContainer.new()

		var label = Label.new()
		label.text = worker.worker_name
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(label)

		var cost = game.family.get_worker_cost(worker)
		var send_button = Button.new()
		send_button.text = "Schicken (%s €)" % game.format_number(cost)
		send_button.disabled = game.money < cost
		send_button.pressed.connect(_on_send_pressed.bind(worker))
		row.add_child(send_button)

		list_container.add_child(row)

func _on_send_pressed(worker: Worker) -> void:
	game.family.recruit_worker(worker)
	rebuild_list()

func _on_close_requested() -> void:
	queue_free()
