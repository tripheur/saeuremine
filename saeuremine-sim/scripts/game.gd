class_name Game
extends Control

@export var saeure_label: Label
@export var geld_label: Label
@export var arbeiter_label: Label
@export var buy_button: Button
@export var sell_button: Button
@export var work_button: Button
@export var save_button: Button
@export var upgrade_button: Button
@export var timer: Timer
@export var log_label: Label

var acid: int = 0
var money: int = 0
var worker_cost: int = 10
var acid_cost: int = 1  # wie viel Säure für 1 Geld beim Verkaufen (später fürs Balancing anpassen)
var total_acid_earned: int = 0
var total_money_earned: int = 0
var total_deaths: int = 0
var family_name: String

var family_pool: Array[Worker] = []
var active_workers: Array[Worker] = []

var player_first_name: String
var player_is_male: bool

var family_names = ["Müller", "Schmidt", "Schneider", "Fischer", "Weber",
					"Wagner", "Becker", "Schulz", "Hoffmann", "Schäfer",
					"Koch", "Bauer", "Richter", "Klein", "Wolf"]

var male_retiree_relations = ["Opa", "Uropa", "Großonkel"]
var female_retiree_relations = ["Oma", "Uroma", "Großtante"]

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

func draw_name(w_type: Worker.Type, is_male: bool) -> String:
	match w_type:
		Worker.Type.ADULT:
			return male_names_adult[randi() % male_names_adult.size()] if is_male else female_names_adult[randi() % female_names_adult.size()]
		Worker.Type.RETIREE:
			return male_names_retiree[randi() % male_names_retiree.size()] if is_male else female_names_retiree[randi() % female_names_retiree.size()]
		Worker.Type.CHILD:
			return male_names_child[randi() % male_names_child.size()] if is_male else female_names_child[randi() % female_names_child.size()]
	return "Unbekannt"

# "dein Onkel Frank" / "deine Tante Monika" - grammatikalisches Geschlecht
# stimmt bei allen verwendeten Verwandtschaftsbegriffen mit is_male überein.
func get_possessive_name(w: Worker) -> String:
	var possessive = "dein" if w.is_male else "deine"
	return "%s %s" % [possessive, w.worker_name]

# Gleiches, aber großgeschrieben für den Satzanfang ("Dein Onkel Frank ...")
func get_possessive_name_capitalized(w: Worker) -> String:
	var name = get_possessive_name(w)
	return name.substr(0, 1).to_upper() + name.substr(1)

func generate_family() -> void:
	family_name = family_names[randi() % family_names.size()]
	player_is_male = randi() % 2 == 0
	player_first_name = draw_name(Worker.Type.ADULT, player_is_male)

	# Jeder Eintrag: is_male, Worker.Type, optionale feste Relation
	# (fehlt "relation", wird sie unten pro Typ zufällig aus den
	# Großeltern-Titeln gezogen - betrifft aktuell nur die Großeltern-Generation)
	var entries: Array = []

	# Großelterngeneration
	var grandparent_count = randi_range(0, 4)
	for i in grandparent_count:
		entries.append({"is_male": randi() % 2 == 0, "type": Worker.Type.RETIREE})

	# Elterngeneration: höchstens eine Mutter, ein Vater
	var has_mother = randf() < 0.85
	var has_father = randf() < 0.85
	if has_mother:
		entries.append({"is_male": false, "type": Worker.Type.ADULT, "relation": "Mutter"})
	if has_father:
		entries.append({"is_male": true, "type": Worker.Type.ADULT, "relation": "Vater"})

	# Tanten/Onkel (Geschwister der Eltern)
	var aunt_uncle_count = randi_range(0, 3)
	for i in aunt_uncle_count:
		var is_m = randi() % 2 == 0
		entries.append({"is_male": is_m, "type": Worker.Type.ADULT, "relation": "Onkel" if is_m else "Tante"})

	# Eigene Geschwister
	var sibling_count = randi_range(0, 3)
	for i in sibling_count:
		var is_m = randi() % 2 == 0
		entries.append({"is_male": is_m, "type": Worker.Type.ADULT, "relation": "Bruder" if is_m else "Schwester"})

	# Cousin/Cousine - nur möglich, wenn es Tanten/Onkel gibt
	if aunt_uncle_count > 0:
		var cousin_count = randi_range(0, max(aunt_uncle_count * 2, 4))
		for i in cousin_count:
			var is_m = randi() % 2 == 0
			entries.append({"is_male": is_m, "type": Worker.Type.ADULT, "relation": "Cousin" if is_m else "Cousine"})

	# Eigene Kinder
	var children_count = randi_range(0, 4)
	for i in children_count:
		var is_m = randi() % 2 == 0
		entries.append({"is_male": is_m, "type": Worker.Type.CHILD, "relation": "Sohn" if is_m else "Tochter"})

	# Neffen/Nichten - nur möglich, wenn es Geschwister gibt
	if sibling_count > 0:
		var niece_nephew_count = randi_range(0, max(sibling_count * 2, 4))
		for i in niece_nephew_count:
			var is_m = randi() % 2 == 0
			entries.append({"is_male": is_m, "type": Worker.Type.CHILD, "relation": "Neffe" if is_m else "Nichte"})

	# Enkel - nur möglich, wenn es eigene Kinder gibt
	if children_count > 0:
		var grandchildren_count = randi_range(0, 3)
		for i in grandchildren_count:
			var is_m = randi() % 2 == 0
			entries.append({"is_male": is_m, "type": Worker.Type.CHILD, "relation": "Enkel" if is_m else "Enkelin"})

	# Fallback: falls komplett leere Familie gewürfelt wurde, nicht mit leerer Mine starten
	if entries.is_empty():
		var is_m = randi() % 2 == 0
		entries.append({"is_male": is_m, "type": Worker.Type.ADULT, "relation": "Onkel" if is_m else "Tante"})

	var used_names: Array = []
	for entry in entries:
		var is_male = entry["is_male"]
		var w_type = entry["type"]
		var relation = entry.get("relation", "")
		if relation == "":
			relation = male_retiree_relations[randi() % male_retiree_relations.size()] if is_male else female_retiree_relations[randi() % female_retiree_relations.size()]

		var first = draw_name(w_type, is_male)
		var full_name = relation + " " + first
		var attempts = 0
		while full_name in used_names and attempts < 10:
			first = draw_name(w_type, is_male)
			full_name = relation + " " + first
			attempts += 1
		used_names.append(full_name)
		family_pool.append(Worker.create(full_name, w_type, is_male))

	# Persönliche Vorstellung: "dein"/"deine" richtet sich nach dem
	# grammatikalischen Geschlecht der Relation, das hier immer mit
	# is_male des Familienmitglieds übereinstimmt (Onkel/Bruder/... sind
	# immer männlich und Tante/Schwester/... immer weiblich)
	var intro_parts = []
	for w in family_pool:
		intro_parts.append(get_possessive_name(w))

	add_log("Du bist %s %s. Deine Familienmitglieder sind: %s." % [player_first_name, family_name, ", ".join(intro_parts)])

func _on_work_button_pressed() -> void:
	acid += 1
	total_acid_earned += 1
	update_labels()

func _on_sell_button_pressed() -> void:
	var amount = acid / acid_cost
	if amount > 0:
		money += amount
		acid -= amount * acid_cost
		total_money_earned += amount
		add_log("%s Säure für %s Geld verkauft." % [amount * acid_cost, amount])
		update_labels()
	else:
		add_log("Nicht genug Säure zum Verkaufen (mind. %s nötig)." % acid_cost)

func get_worker_cost(worker: Worker) -> int:
	# Aktuell einheitlicher Preis für alle - falls du später nach Typ
	# staffeln willst (z.B. Kinder günstiger, Omas teurer o.ä.), hier
	# per worker.type unterscheiden.
	return worker_cost

func recruit_worker(worker: Worker) -> void:
	var cost = get_worker_cost(worker)
	if money >= cost and family_pool.has(worker):
		money -= cost
		family_pool.erase(worker)
		active_workers.append(worker)
		worker_cost = int(worker_cost * 1.1)
		add_log("%s wurde in die Mine geschickt." % get_possessive_name_capitalized(worker))
		update_labels()

func _on_buy_button_pressed() -> void:
	if family_pool.is_empty():
		return
	var popup = preload("res://scenes/recruit_popup.tscn").instantiate()
	add_child(popup)
	popup.setup(self)
	popup.popup_centered()

func _on_upgrade_button_pressed() -> void:
	# TODO: sobald die Upgrade-Szene existiert, hier das Popup instanzieren/anzeigen
	# z.B. var popup = preload("res://scenes/upgrade_popup.tscn").instantiate()
	#      add_child(popup)
	#      popup.setup(money)  # damit das Popup weiß, was sich der Spieler leisten kann
	pass

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
		money += w.inheritance
		total_money_earned += w.inheritance
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
	var msg = msg_template % get_possessive_name_capitalized(w)
	var full_msg = msg + " %s vererbt dir %s €." % [pronoun, w.inheritance]
	add_log(full_msg)
	Global.last_death_note = full_msg

func add_log(text: String) -> void:
	log_label.text = text + "\n" + log_label.text

func update_labels() -> void:
	saeure_label.text = "Säure: %s" % acid
	geld_label.text = "Vermögen: %s" % money
	arbeiter_label.text = "Arbeiter: %s | Familie: %s" % [active_workers.size(), family_pool.size()]
	update_buy_button()
	update_sell_button()

func update_buy_button() -> void:
	if family_pool.size() == 0:
		buy_button.text = "keine Familienmitglieder übrig"
		buy_button.disabled = true
	else:
		buy_button.text = "Familienmitglied schicken (ab %s €)" % worker_cost
		buy_button.disabled = money < worker_cost

func update_sell_button() -> void:
	sell_button.text = "Säure verkaufen (%s €/Liter)" % acid_cost
	sell_button.disabled = acid < acid_cost

func check_game_over() -> void:
	if family_pool.size() == 0 and active_workers.size() == 0:
		timer.stop()
		# Highscore prüfen und speichern
		var hs = SaveManager.load_highscore()
		if hs.is_empty() or total_acid_earned > int(hs.get("total_acid", 0)):
			SaveManager.save_highscore({
				"total_acid": total_acid_earned,
				"total_money": total_money_earned,
				"total_deaths": total_deaths,
				"family_name": family_name
			})
		# Daten für GameOver-Screen
		Global.game_over_data = {
			"total_acid": total_acid_earned,
			"total_money": total_money_earned,
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
		"money": money,
		"worker_cost": worker_cost,
		"total_acid_earned": total_acid_earned,
		"total_money_earned": total_money_earned,
		"total_deaths": total_deaths,
		"family_name": family_name,
		"player_first_name": player_first_name,
		"player_is_male": player_is_male,
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
	money = int(data.get("money", 0))
	worker_cost = int(data.get("worker_cost", 10))
	total_acid_earned = int(data.get("total_acid_earned", 0))
	total_money_earned = int(data.get("total_money_earned", 0))
	total_deaths = int(data.get("total_deaths", 0))
	family_name = data.get("family_name", "Unbekannt")
	player_first_name = data.get("player_first_name", "Unbekannt")
	player_is_male = bool(data.get("player_is_male", true))

	for w_data in data.get("active_workers", []):
		var w = Worker.create(w_data.name, w_data.type, w_data.is_male)
		w.age = float(w_data.age)
		active_workers.append(w)

	for w_data in data.get("family_pool", []):
		var w = Worker.create(w_data.name, w_data.type, w_data.is_male)
		family_pool.append(w)

	add_log("Spielstand geladen. Willkommen zurück, Familie %s." % family_name)
