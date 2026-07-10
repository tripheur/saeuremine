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
@export var health_bar: ProgressBar  # siehe Hinweis in _ready(), falls noch nicht verlinkt
@export var karma_label: Label       # siehe Hinweis in _ready(), falls noch nicht verlinkt

var acid: int = 0
var money: int = 0
var acid_cost: int = 1  # wie viel Säure für 1 Geld beim Verkaufen (später fürs Balancing anpassen)
var total_acid_earned: int = 0
var total_money_earned: int = 0
var total_deaths: int = 0
var family_name: String

var player_max_health: int = 100
var player_health: int = 100
var work_health_cost: int = 3    # Gesundheitsverlust pro Klick auf "Schuften"
var health_regen_per_tick: int = 0  # Regeneration pro Timer-Tick (aktuell 1x/Sekunde), wenn nicht gearbeitet wird
var karma: int = 0

var family_pool: Array[Worker] = []
var active_workers: Array[Worker] = []

var player_first_name: String
var player_is_male: bool

# Ausgelagerte Teilsysteme - siehe family_generator.gd und upgrade_system.gd.
# Beide halten eine Rückreferenz auf dieses Game-Objekt (game.family, game.upgrades),
# damit Popups und andere Skripte z.B. game.upgrades.buy_upgrade(id) aufrufen können.
# Erzeugung erst in _ready() (nicht direkt hier), um zirkuläre Typ-Auflösung
# beim Parsen zu vermeiden - siehe Kommentar in family_generator.gd.
var family: FamilyGenerator
var upgrades: UpgradeSystem

func _ready() -> void:
	family = FamilyGenerator.new()
	upgrades = UpgradeSystem.new()
	family.game = self
	upgrades.game = self

	if not health_bar:
		push_warning("health_bar ist nicht gesetzt - Gesundheit wird nirgends angezeigt. In game.tscn eine ProgressBar hinzufügen und im Inspector des Game-Node auf 'Health Bar' verlinken.")
	if not karma_label:
		push_warning("karma_label ist nicht gesetzt - Karma wird nirgends angezeigt. In game.tscn ein Label hinzufügen und im Inspector des Game-Node auf 'Karma Label' verlinken.")

	timer.timeout.connect(_on_timer_timeout)
	if SaveManager.save_exists():
		load_game()
	else:
		family.generate_family()
	update_labels()

# Formatiert große Zahlen mit Tausenderpunkten (12345 -> "12.345"),
# damit Beträge nicht mehr als unübersichtlicher Zahlenwurm dastehen.
# Formatiert große Zahlen mit Tausenderpunkten (12345 -> "12.345"),
# damit Beträge nicht mehr als unübersichtlicher Zahlenwurm dastehen.
# Siehe number_format.gd - dieselbe Funktion nutzt auch game_over.gd.
func format_number(n: int) -> String:
	return NumberFormat.with_dots(n)

func _on_work_button_pressed() -> void:
	if player_health <= 0:
		return
	acid += 1
	total_acid_earned += 1
	player_health = max(0, player_health - work_health_cost)
	update_labels()
	if player_health <= 0:
		player_dies()

func _on_sell_button_pressed() -> void:
	var groups = acid / acid_cost
	if groups > 0:
		var payout = int(round(groups * upgrades.get_sell_multiplier()))
		money += payout
		acid -= groups * acid_cost
		total_money_earned += payout
		add_log("%s Säure für %s Geld verkauft." % [format_number(groups * acid_cost), format_number(payout)])
		update_labels()
	else:
		add_log("Nicht genug Säure zum Verkaufen (mind. %s nötig)." % acid_cost)

func _on_buy_button_pressed() -> void:
	if family_pool.is_empty():
		return
	var popup = preload("res://scenes/recruit_popup.tscn").instantiate()
	add_child(popup)
	popup.setup(self)
	popup.popup_centered()

func _on_upgrade_button_pressed() -> void:
	var popup = preload("res://scenes/upgrade_popup.tscn").instantiate()
	add_child(popup)
	popup.setup(self)
	popup.popup_centered()

func _on_timer_timeout() -> void:
	var to_remove: Array[Worker] = []

	for w in active_workers:
		var produced = int(round(w.production * upgrades.get_production_multiplier()))
		acid += produced
		total_acid_earned += produced
		w.age += 1.0
		if w.age >= w.lifetime * upgrades.get_lifetime_multiplier():
			to_remove.append(w)

	for w in to_remove:
		active_workers.erase(w)
		money += w.inheritance
		total_money_earned += w.inheritance
		total_deaths += 1
		karma += -3 if w.is_family else -1
		family.show_death_message(w)

	# Regeneration, wenn man nicht selbst schuftet
	if player_health < player_max_health:
		player_health = min(player_max_health, player_health + health_regen_per_tick)

	update_labels()

func player_dies() -> void:
	timer.stop()
	work_button.disabled = true

	var spared = family_pool.size()
	karma += spared * 5
	add_log("Du bist zusammengebrochen - dein Körper macht nicht mehr mit. %s Familienmitglieder blieben verschont." % spared)

	var hs = SaveManager.load_highscore()
	if hs.is_empty() or total_money_earned > int(hs.get("total_money", 0)):
		SaveManager.save_highscore({
			"total_acid": total_acid_earned,
			"total_money": total_money_earned,
			"total_deaths": total_deaths,
			"karma": karma,
			"family_name": family_name
		})

	Global.game_over_data = {
		"total_acid": total_acid_earned,
		"total_money": total_money_earned,
		"total_deaths": total_deaths,
		"karma": karma,
		"spared": spared,
		"family_name": family_name
	}
	SaveManager.delete_save()
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")

func add_log(text: String) -> void:
	log_label.text = text + "\n" + log_label.text

func update_labels() -> void:
	saeure_label.text = "Säure: %s" % format_number(acid)
	geld_label.text = "Vermögen: %s €" % format_number(money)
	arbeiter_label.text = "Arbeiter: %s | Familie: %s" % [active_workers.size(), family_pool.size()]
	if health_bar:
		health_bar.max_value = player_max_health
		health_bar.value = player_health
	if karma_label:
		karma_label.text = "Karma: %s" % karma
	update_buy_button()
	update_sell_button()

func update_buy_button() -> void:
	if family_pool.size() == 0:
		buy_button.text = "keine Familienmitglieder übrig"
		buy_button.disabled = true
	else:
		var cost = family.get_worker_cost(family_pool[0])
		buy_button.text = "Familienmitglied schicken (ab %s €)" % format_number(cost)
		buy_button.disabled = money < cost

func update_sell_button() -> void:
	var effective_rate = upgrades.get_sell_multiplier() / float(acid_cost)
	sell_button.text = "Säure verkaufen (%.2f €/Liter)" % effective_rate
	sell_button.disabled = acid < acid_cost

func _on_save_button_pressed() -> void:
	save_game()

func save_game() -> void:
	var workers_data = []
	for w in active_workers:
		workers_data.append({
			"name": w.worker_name,
			"type": w.type,
			"is_male": w.is_male,
			"is_family": w.is_family,
			"age": w.age
		})

	var pool_data = []
	for w in family_pool:
		pool_data.append({
			"name": w.worker_name,
			"type": w.type,
			"is_male": w.is_male,
			"is_family": w.is_family,
			"age": w.age
		})

	SaveManager.save_game({
		"acid": acid,
		"money": money,
		"worker_cost": family.worker_cost,
		"total_acid_earned": total_acid_earned,
		"total_money_earned": total_money_earned,
		"total_deaths": total_deaths,
		"family_name": family_name,
		"player_first_name": player_first_name,
		"player_is_male": player_is_male,
		"player_health": player_health,
		"karma": karma,
		"upgrade_levels": upgrades.upgrade_levels,
		"active_workers": workers_data,
		"family_pool": pool_data
	})
	add_log("Spielstand gespeichert.")

func load_game() -> void:
	var data = SaveManager.load_game()
	if data.is_empty():
		family.generate_family()
		return

	acid = int(data.get("acid", 0))
	money = int(data.get("money", 0))
	family.worker_cost = int(data.get("worker_cost", 10))
	total_acid_earned = int(data.get("total_acid_earned", 0))
	total_money_earned = int(data.get("total_money_earned", 0))
	total_deaths = int(data.get("total_deaths", 0))
	family_name = data.get("family_name", "Unbekannt")
	player_first_name = data.get("player_first_name", "Unbekannt")
	player_is_male = bool(data.get("player_is_male", true))
	player_health = int(data.get("player_health", player_max_health))
	karma = int(data.get("karma", 0))

	var loaded_levels = data.get("upgrade_levels", {})
	for key in upgrades.upgrade_levels.keys():
		upgrades.upgrade_levels[key] = int(loaded_levels.get(key, 0))

	for w_data in data.get("active_workers", []):
		var w = Worker.create(w_data.name, w_data.type, w_data.is_male, w_data.get("is_family", true))
		w.age = float(w_data.age)
		active_workers.append(w)

	for w_data in data.get("family_pool", []):
		var w = Worker.create(w_data.name, w_data.type, w_data.is_male, w_data.get("is_family", true))
		family_pool.append(w)

	add_log("Spielstand geladen. Willkommen zurück, Familie %s." % family_name)
