class_name MainMenu
extends Control

@export var highscore_label: Label
@export var start_button: Button
@export var load_button: Button

func _ready() -> void:
	var hs = SaveManager.load_highscore()
	if hs.is_empty():
		highscore_label.text = "Noch kein Highscore vorhanden."
	else:
		highscore_label.text = "Highscore: %s Säure\nFamilie %s – %s Mitglieder verheizt" % [
			hs.total_acid, hs.family_name, hs.total_deaths
		]
	
	load_button.disabled = not SaveManager.save_exists()

func _on_start_button_pressed() -> void:
	SaveManager.delete_save()
	Global.game_over_data = {}
	Global.last_death_note = ""
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_load_button_pressed() -> void:
	get_tree().change_scene_to_file("res://game.tscn")
