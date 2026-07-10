class_name FamilyGenerator
extends RefCounted

# Rückverweis auf die Game-Node, um auf geteilten Zustand zuzugreifen
# (family_pool, active_workers, money, karma, family_name, ...).
var game: Game

var worker_cost: int = 10

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

func draw_name(w_type: Worker.Type, is_male: bool) -> String:
	match w_type:
		Worker.Type.ADULT:
			return male_names_adult[randi() % male_names_adult.size()] if is_male else female_names_adult[randi() % female_names_adult.size()]
		Worker.Type.RETIREE:
			return male_names_retiree[randi() % male_names_retiree.size()] if is_male else female_names_retiree[randi() % female_names_retiree.size()]
		Worker.Type.CHILD:
			return male_names_child[randi() % male_names_child.size()] if is_male else female_names_child[randi() % female_names_child.size()]
	return "Unbekannt"

func generate_family() -> void:
	game.family_name = family_names[randi() % family_names.size()]
	game.player_is_male = randi() % 2 == 0
	game.player_first_name = draw_name(Worker.Type.ADULT, game.player_is_male)

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
		game.family_pool.append(Worker.create(full_name, w_type, is_male))

	# Persönliche Vorstellung: "dein"/"deine" richtet sich nach dem
	# grammatikalischen Geschlecht der Relation, das hier immer mit
	# is_male des Familienmitglieds übereinstimmt (Onkel/Bruder/... sind
	# immer männlich und Tante/Schwester/... immer weiblich)
	var intro_parts = []
	for w in game.family_pool:
		intro_parts.append(get_possessive_name(w))

	game.add_log("Du bist %s %s. Deine Familienmitglieder sind: %s." % [game.player_first_name, game.family_name, ", ".join(intro_parts)])

# "dein Onkel Frank" / "deine Tante Monika" - grammatikalisches Geschlecht
# stimmt bei allen verwendeten Verwandtschaftsbegriffen mit is_male überein.
func get_possessive_name(w: Worker) -> String:
	var possessive = "dein" if w.is_male else "deine"
	return "%s %s" % [possessive, w.worker_name]

# Gleiches, aber großgeschrieben für den Satzanfang ("Dein Onkel Frank ...")
func get_possessive_name_capitalized(w: Worker) -> String:
	var name = get_possessive_name(w)
	return name.substr(0, 1).to_upper() + name.substr(1)

# Für Fremde (is_family = false) gibt es kein "dein/deine" - die gehören
# ja nicht zur Familie. Diese beiden Funktionen wählen automatisch die
# richtige Variante und sollten überall verwendet werden, wo ein Worker
# im Log auftaucht (Sterbe-Meldung, Rekrutieren-Meldung etc.).
func get_display_name(w: Worker) -> String:
	if w.is_family:
		return get_possessive_name(w)
	return w.worker_name

func get_display_name_capitalized(w: Worker) -> String:
	if w.is_family:
		return get_possessive_name_capitalized(w)
	return w.worker_name

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
	var msg = msg_template % get_display_name_capitalized(w)
	var full_msg = msg + " %s hinterlässt dir zuletzt %s €." % [pronoun, w.inheritance]
	game.add_log(full_msg)
	Global.last_death_note = full_msg

# Gemeinsame Logik zum nachträglichen Hinzufügen von Familienmitgliedern
# (z.B. durch Waisenhaus/Altersheim), inklusive Kollisionsprüfung wie in
# generate_family().
func add_recruits(count: int, w_type: Worker.Type, relation_male: String, relation_female: String) -> void:
	var used_names: Array = []
	for w in game.family_pool:
		used_names.append(w.worker_name)
	for i in count:
		var is_m = randi() % 2 == 0
		var relation = relation_male if is_m else relation_female
		var first = draw_name(w_type, is_m)
		var full_name = relation + " " + first
		var attempts = 0
		while full_name in used_names and attempts < 10:
			first = draw_name(w_type, is_m)
			full_name = relation + " " + first
			attempts += 1
		used_names.append(full_name)
		game.family_pool.append(Worker.create(full_name, w_type, is_m))

# Nachname für Fremde - bewusst nicht der eigene family_name, damit klar
# ist, dass sie nicht verwandt sind.
func draw_outsider_surname() -> String:
	var options = family_names.filter(func(n): return n != game.family_name)
	if options.is_empty():
		return family_names[randi() % family_names.size()]
	return options[randi() % options.size()]

# Fremde landen NICHT in family_pool und tauchen nirgends im
# Rekrutieren-Popup auf - sie werden beim Kauf sofort in active_workers
# gesteckt. forced_is_male erlaubt feste Geschlechter für Kontexte wie
# "Nachbarsjunge" (per Definition männlich); bei null wird gewürfelt.
func hire_outsider(w_type: Worker.Type, context: String, forced_is_male = null) -> void:
	var is_m = forced_is_male if forced_is_male != null else (randi() % 2 == 0)
	var first = draw_name(w_type, is_m)
	var last = draw_outsider_surname()
	var full_name = "%s %s" % [first, last]
	var w = Worker.create(full_name, w_type, is_m, false)
	game.active_workers.append(w)
	game.add_log("%s (%s) wird direkt in die Mine geschickt." % [full_name, context])

func get_worker_cost(worker: Worker) -> int:
	# Aktuell einheitlicher Preis für alle (nur durch das
	# "Schuldgefühle wecken"-Upgrade rabattiert) - falls du später nach Typ
	# staffeln willst, hier per worker.type unterscheiden.
	return int(round(worker_cost * game.upgrades.get_recruit_discount()))

func recruit_worker(worker: Worker) -> void:
	var cost = get_worker_cost(worker)
	if game.money >= cost and game.family_pool.has(worker):
		game.money -= cost
		game.family_pool.erase(worker)
		game.active_workers.append(worker)
		worker_cost = int(round(worker_cost * 1.1))
		game.add_log("%s wurde in die Mine geschickt." % get_possessive_name_capitalized(worker))
		game.update_labels()
