class_name GameOver
extends Control

@export var stats_label: Label
@export var highscore_label: Label
@export var death_note_label: Label

func _ready() -> void:
	var data = Global.game_over_data
	stats_label.text = "Familie %s ist vollständig verbraucht.\n%s Mitglieder verheizt.\n%s Säure gefördert.\n%s € verdient." % [
		data.get("family_name", "Unbekannt"),
		data.get("total_deaths", 0),
		data.get("total_acid", 0),
		data.get("total_money", 0)
	]
	var hs = SaveManager.load_highscore()
	if hs.is_empty():
		highscore_label.text = ""
	else:
		highscore_label.text = "Highscore: %s Säure, %s € – Familie %s" % [hs.total_acid, hs.get("total_money", 0), hs.family_name]
	if Global.last_death_note != "":
		death_note_label.text = "Zuletzt gesehen: " + Global.last_death_note
	else:
		death_note_label.text = ""

func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_restart_button_pressed() -> void:
	SaveManager.delete_save()
	Global.last_death_note = ""
	Global.game_over_data = {}
	get_tree().change_scene_to_file("res://scenes/game.tscn")
