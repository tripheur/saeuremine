class_name UpgradeSystem
extends RefCounted

# Siehe family_generator.gd - bewusst untypisiert, gleicher Grund.
var game

# Upgrade-Level pro Upgrade-ID (0 = noch nicht gekauft)
var upgrade_levels: Dictionary = {
	"production": 0,
	"lifetime": 0,
	"work_yourself": 0,
	"recruit_discount": 0,
	"sell_rate": 0,
	"neighbor_kid": 0,
	"day_laborer": 0,
	"regenerate": 0
}

# "growth" ist der Multiplikator PRO STUFE (z.B. 1.25 = +25% je Stufe,
# multipliziert auf den jeweils aktuellen Wert - nicht linear addiert).
# "karma" ist der Karma-Verlust beim Kauf. "neighbor_kid"/"day_laborer"
# haben keinen Effekt-Multiplikator, sondern lösen hire_outsider() aus
# (siehe buy_upgrade()).
var upgrade_defs: Dictionary = {
	"production": {"name": "Eimer haben jetzt Henkel", "desc": "Säure-Produktion x1.25 pro Stufe", "base_cost": 50, "cost_growth": 1.6, "effect_growth": 1.25, "karma": -2},
	"lifetime": {"name": "Pausen? Abgeschafft", "desc": "Lebenszeit-Produktion x1.2 pro Stufe", "base_cost": 60, "cost_growth": 1.6, "effect_growth": 1.2, "karma": -8},
	"work_yourself": {"name": "Do it yourself", "desc": "Selber Schuften x1.2 pro Stufe", "base_cost": 100, "cost_growth": 1.6, "effect_growth": 1.25, "karma": -2},
	"recruit_discount": {"name": "Schuldgefühle wecken", "desc": "Rekrutierungskosten x0.9 pro Stufe", "base_cost": 80, "cost_growth": 1.8, "effect_growth": 1.2, "max_level": 8, "karma": +10},
	"sell_rate": {"name": "Kartellabsprachen", "desc": "Erlös beim Säureverkauf x1.2 pro Stufe", "base_cost": 70, "cost_growth": 1.6, "effect_growth": 1.2, "karma": -4},
	"neighbor_kid": {"name": "Nachbarsjungen überreden", "desc": "Ein fremdes Kind wird sofort in die Mine geschickt - kein Familienmitglied, taucht nirgends sonst auf", "base_cost": 30, "cost_growth": 1.3, "karma": -3},
	"day_laborer": {"name": "Tagelöhner anheuern", "desc": "Eine fremde erwachsene Person wird sofort in die Mine geschickt - kein Familienmitglied", "base_cost": 70, "cost_growth": 1.4, "karma": -3},
	"regenerate": {"name": "Selbstheilungskräfte", "desc": "Du kannst deine Gesundheit minimal regenerieren", "base_cost": 10.000, "cost_growth": 1.4, "karma": +3},
}

func get_production_multiplier() -> float:
	return pow(upgrade_defs["production"].effect_growth, upgrade_levels["production"])

func get_lifetime_multiplier() -> float:
	return pow(upgrade_defs["lifetime"].effect_growth, upgrade_levels["lifetime"])

func get_recruit_discount() -> float:
	return pow(upgrade_defs["recruit_discount"].effect_growth, upgrade_levels["recruit_discount"])

func get_sell_multiplier() -> float:
	return pow(upgrade_defs["sell_rate"].effect_growth, upgrade_levels["sell_rate"])

func get_upgrade_cost(id: String) -> int:
	var def = upgrade_defs[id]
	return int(round(def.base_cost * pow(def.cost_growth, upgrade_levels[id])))

func can_buy_upgrade(id: String) -> bool:
	var def = upgrade_defs[id]
	if def.has("max_level") and upgrade_levels[id] >= def.max_level:
		return false
	return game.money >= get_upgrade_cost(id)

func buy_upgrade(id: String) -> void:
	if not can_buy_upgrade(id):
		return
	var cost = get_upgrade_cost(id)
	game.money -= cost
	game.karma += upgrade_defs[id].get("karma", -5)
	upgrade_levels[id] += 1
	match id:
		"neighbor_kid":
			game.family.hire_outsider(Worker.Type.CHILD, "Nachbarsjunge", true)
		"day_laborer":
			game.family.hire_outsider(Worker.Type.ADULT, "Tagelöhner")
	game.update_labels()
