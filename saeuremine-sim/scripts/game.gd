class_name Game
extends Control

@export var saeure_label: Label
@export var arbeiter_label: Label
@export var buy_button: Button
@export var work_button: Button
@export var save_button: Button
@export var timer: Timer
@export var log_label: Label

var acid: int = 0
var worker_cost: int = 10
var total_acid_earned: int = 0
var total_deaths: int = 0
var family_name: String

var family_pool: Array[Worker] = []
var active_workers: Array[Worker] = []

var family_names = ["Müller", "Schmidt", "Schneider", "Fischer", "Weber",
					"Wagner", "Becker", "Schulz", "Hoffmann", "Schäfer",
					"Koch", "Bauer", "Richter", "Klein", "Wolf"]

var male_adult_relations = ["Onkel", "Bruder", "Cousin"]
var female_adult_relations = ["Tante", "Schwester", "Cousine"]
var male_retiree_relations = ["Opa", "Uropa", "Großonkel"]
var female_retiree_relations = ["Oma", "Uroma", "Großtante"]
var male_child_relations = ["Neffe", "Enkel"]
var female_child_relations = ["Nichte", "Enkelin"]

var male_names_adult = ["Herbert", "Klaus", "Dieter", "Rüdiger", "Peter", "Bernd", "Frank"]
var female_names_adult = ["Monika", "Hannelore", "Brigitte", "Waltraud", "Anna", "Petra", "Gabi"]
var male_names_retiree = ["Helmut", "Siegfried", "Waldemar", "Horst", "Günter", "Erich"]
var female_names_retiree = ["Gertrude", "Irmgard", "Hildegard", "Elfriede", "Lieselotte"]
var male_names_child = ["Tim", "Max", "Paul", "Felix", "Leon", "Lukas"]
var female_names_child = ["Lisa", "Emma", "Lena", "Marie", "Sophie", "Hannah"]

var death_messages_male = [
	"%s wollte mal kurz schauen wie tief das Loch ist.",
	"%s hat die Schutzausrüstung als unnötig erachtet.",
	"%s ist beim Überstundenmachen eingeschlafen. Für immer.",
	"%s hat eine interne Beförderung erhalten. Nach unten.",
	"%s meinte, so schlimm könne die Säure ja nicht sein.",
	"%s hat den Unternehmensgeist bis zuletzt gelebt.",
	"%s wollte eigentlich nächste Woche aufhören.",
]
var death_messages_female = [
	"%s ist in die falsche Säurepfütze getreten.",
	"%s wollte nur kurz nach dem Rechten sehen.",
	"%s ist ausgerutscht. Unglücklicher Zufall.",
	"%s fragte zuletzt, wann Pause ist.",
	"%s hatte noch so viele Pläne.",
	"%s meinte, Säure sei doch übertrieben als Warnung.",
	"%s wollte eigentlich nächste Woche aufhören.",
]
var death_messages_child_male = [
	"%s wollte nur kurz spielen gehen.",
	"%s hat die Warnschilder noch nicht lesen können.",
	"%s fragte zuletzt, wann er nach Hause darf.",
	"%s hatte noch so viele Träume.",
]
var death_messages_child_female = [
	"%s wollte nur kurz spielen gehen.",
	"%s hat die Warnschilder noch nicht lesen können.",
	"%s fragte zuletzt, wann sie nach Hause darf.",
	"%s hatte noch so viele Träume.",
]

func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)
	if SaveManager.save_exists():
		load_game()
	else:
		generate_family()
	update_labels()
	update_buy_button()

func generate_family() -> void:
	family_name = family_names[randi() % family_names.size()]
	var size = randi_range(3, 30)
	var used_names: Array = []

	for i in size:
		var random_type = randi() % 3
		var w_type = Worker.Type.values()[random_type]
		var is_male = randi() % 2 == 0
		var relation: String
		var first: String

		match w_type:
			Worker.Type.ADULT:
				if is_male:
					relation = male_adult_relations[randi() % male_adult_relations.size()]
					first = male_names_adult[randi() % male_names_adult.size()]
				else:
					relation = female_adult_relations[randi() % female_adult_relations.size()]
					first = female_names_adult[randi() % female_names_adult.size()]
			Worker.Type.RETIREE:
				if is_male:
					relation = male_retiree_relations[randi() % male_retiree_relations.size()]
					first = male_names_retiree[randi() % male_names_retiree.size()]
				else:
					relation = female_retiree_relations[randi() % female_retiree_relations.size()]
					first = female_names_retiree[randi() % female_names_retiree.size()]
			Worker.Type.CHILD:
				if is_male:
					relation = male_child_relations[randi() % male_child_relations.size()]
					first = male_names_child[randi() % male_names_child.size()]
				else:
					relation = female_child_relations[randi() % female_child_relations.size()]
					first = female_names_child[randi() % female_names_child.size()]

		var full_name = relation + " " + first
		var attempts = 0
		while full_name in used_names and attempts < 10:
			if is_male:
				first = male_names_adult[randi() % male_names_adult.size()]
			else:
				first = female_names_adult[randi() % female_names_adult.size()]
			full_name = relation + " " + first + " " + family_name
			attempts += 1
		used_names.append(full_name)
		family_pool.append(Worker.create(full_name, w_type, is_male))

	var names = []
	for w in family_pool:
		names.append(w.worker_name)
	add_log("Familie %s hat %s Mitglieder: %s" % [family_name, family_pool.size(), ", ".join(names)])

func _on_work_button_pressed() -> void:
	acid += 1
	total_acid_earned += 1
	update_labels()

func _on_buy_button_pressed() -> void:
	if acid >= worker_cost and family_pool.size() > 0:
		acid -= worker_cost
		var new_worker = family_pool.pop_front()
		active_workers.append(new_worker)
		worker_cost = int(worker_cost * 1.1)
		add_log("%s wurde in die Mine geschickt." % new_worker.worker_name)
		update_labels()
		update_buy_button()

func _on_timer_timeout() -> void:
	var to_remove: Array[Worker] = []

	for w in active_workers:
		acid += w.production
		total_acid_earned += w.production
		w.age += 1.0
		if w.age >= w.lifetime:
			to_remove.append(w)

	for w in to_remove:
		active_workers.erase(w)
		acid += w.inheritance
		total_acid_earned += w.inheritance
		total_deaths += 1
		show_death_message(w)

	update_labels()
	check_game_over()

func show_death_message(w: Worker) -> void:
	var messages: Array
	match w.type:
		Worker.Type.ADULT:
			messages = death_messages_male if w.is_male else death_messages_female
		Worker.Type.RETIREE:
			messages = death_messages_male if w.is_male else death_messages_female
		Worker.Type.CHILD:
			messages = death_messages_child_male if w.is_male else death_messages_child_female

	var msg_template = messages[randi() % messages.size()]
	var pronoun = "Er" if w.is_male else "Sie"
	var msg = msg_template % w.worker_name
	var full_msg = msg + " %s vererbt dir %s Säure." % [pronoun, w.inheritance]
	add_log(full_msg)
	Global.last_death_note = full_msg

func add_log(text: String) -> void:
	log_label.text = text + "\n" + log_label.text

func update_labels() -> void:
	saeure_label.text = "Säure: %s" % acid
	arbeiter_label.text = "Arbeiter: %s | Familie: %s" % [active_workers.size(), family_pool.size()]

func update_buy_button() -> void:
	if family_pool.size() == 0:
		buy_button.text = "Familie erschöpft"
		buy_button.disabled = true
	else:
		buy_button.text = "Rekrutieren: %s Säure" % worker_cost
		buy_button.disabled = false

func check_game_over() -> void:
	if family_pool.size() == 0 and active_workers.size() == 0:
		timer.stop()
		# Highscore prüfen und speichern
		var hs = SaveManager.load_highscore()
		if hs.is_empty() or total_acid_earned > int(hs.get("total_acid", 0)):
			SaveManager.save_highscore({
				"total_acid": total_acid_earned,
				"total_deaths": total_deaths,
				"family_name": family_name
			})
		# Daten für GameOver-Screen
		Global.game_over_data = {
			"total_acid": total_acid_earned,
			"total_deaths": total_deaths,
			"family_name": family_name
		}
		SaveManager.delete_save()
		get_tree().change_scene_to_file("res://scenes/game_over.tscn")

func _on_save_button_pressed() -> void:
	save_game()

func save_game() -> void:
	var workers_data = []
	for w in active_workers:
		workers_data.append({
			"name": w.worker_name,
			"type": w.type,
			"is_male": w.is_male,
			"age": w.age
		})

	var pool_data = []
	for w in family_pool:
		pool_data.append({
			"name": w.worker_name,
			"type": w.type,
			"is_male": w.is_male,
			"age": w.age
		})

	SaveManager.save_game({
		"acid": acid,
		"worker_cost": worker_cost,
		"total_acid_earned": total_acid_earned,
		"total_deaths": total_deaths,
		"family_name": family_name,
		"active_workers": workers_data,
		"family_pool": pool_data
	})
	add_log("Spielstand gespeichert.")

func load_game() -> void:
	var data = SaveManager.load_game()
	if data.is_empty():
		generate_family()
		return

	acid = int(data.get("acid", 0))
	worker_cost = int(data.get("worker_cost", 10))
	total_acid_earned = int(data.get("total_acid_earned", 0))
	total_deaths = int(data.get("total_deaths", 0))
	family_name = data.get("family_name", "Unbekannt")

	for w_data in data.get("active_workers", []):
		var w = Worker.create(w_data.name, w_data.type, w_data.is_male)
		w.age = float(w_data.age)
		active_workers.append(w)

	for w_data in data.get("family_pool", []):
		var w = Worker.create(w_data.name, w_data.type, w_data.is_male)
		family_pool.append(w)

	add_log("Spielstand geladen. Willkommen zurück, Familie %s." % family_name)
