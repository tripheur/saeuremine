extends Node

const SAVE_PATH = "user://savegame.json"
const HIGHSCORE_PATH = "user://highscore.json"

# Spielstand speichern
func save_game(data: Dictionary) -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()

# Spielstand laden
func load_game() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	return data if data else {}

# Spielstand löschen
func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)

# Prüfen ob Savegame existiert
func save_exists() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

# Highscore speichern
func save_highscore(data: Dictionary) -> void:
	var file = FileAccess.open(HIGHSCORE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()

# Highscore laden
func load_highscore() -> Dictionary:
	if not FileAccess.file_exists(HIGHSCORE_PATH):
		return {}
	var file = FileAccess.open(HIGHSCORE_PATH, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	return data if data else {}
