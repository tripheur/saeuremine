# TODO

## Offene Punkte

### 1. Feature: Upgrades fertig machen

- **Kontext:** Geld-System läuft (Säure verkaufen, Arbeiter kosten Geld,
  Kaufen-/Verkaufen-Buttons grauen korrekt aus). `_on_upgrade_button_pressed()`
  in `game.gd` ist aktuell nur ein Stub mit TODO-Kommentar.
- **Umzusetzen:**
  - Popup-Szene für Upgrades (Fenster mit Liste an Angeboten)
  - Angebote sind ausgegraut/nicht klickbar, wenn nicht genug Geld vorhanden
    ist (analog zur `disabled`-Logik von `buy_button`/`sell_button`)
  - `_on_upgrade_button_pressed()` instanziert das Popup und übergibt den
    aktuellen `money`-Stand
- **Offene Designfrage:** Was genau kann man kaufen außer neuen Arbeitern?

### 2. Log überarbeiten

- **Problem:** Der Log (`ScrollContainer/Loglabel`) ist zu klein und
  schlecht lesbar (aktuell `font_size = 12`).
- **Zusätzlich:** Die Anzeige der Familienmitglieder zu Spielbeginn
  (`generate_family()` → `add_log("Familie %s hat %s Mitglieder: ...")`)
  gefällt so nicht – vermutlich zu textlastig/unübersichtlich bei großen
  Familien (bis zu 30 Mitglieder als eine lange Komma-Liste).
- **Zu klären:** Eigene Formatierung/Layout für die Anfangsmeldung
  (z.B. nach Typ gruppiert, oder nur Anzahl statt komplette Namensliste),
  plus generelles Redesign von Schriftgröße/Kontrast/Platz des Logs.

### 3. Feature: Auswahl, welches Familienmitglied in die Mine geschickt wird

- **Kontext:** Aktuell holt `_on_buy_button_pressed()` immer stumpf das
  erste Element aus `family_pool` (`family_pool.pop_front()`). Die
  Worker-Typen (`Worker.Type.ADULT/RETIREE/CHILD`) haben schon
  unterschiedliche Werte für `production`, `lifetime` und `inheritance`
  (siehe `worker.gd`) – das aber ist der Spielerin bisher nicht zugänglich.
- **Umzusetzen:** UI, um aus `family_pool` gezielt ein Mitglied auszuwählen
  statt automatisch das erste zu nehmen. Vor-/Nachteile der Typen sollten
  dabei sichtbar sein (schnell tot & viel Erbe vs. lange & wenig Produktion
  etc.).

### 4. Feature: Beenden-Button

- **Kontext:** Nach dem Speichern gibt es aktuell keine Möglichkeit, das
  Hauptspiel zu verlassen (kein Zurück zum Hauptmenü oder App-Exit aus
  `game.tscn` heraus).
- **Umzusetzen:** Neuer Button in `game.tscn`, analog zu `menu_button` in
  `game_over.tscn`. Auf Desktop vermutlich `get_tree().quit()`, auf
  Android/für Zurück-zum-Menü eher `change_scene_to_file("res://scenes/main_menu.tscn")`
  – zu klären, was hier gewünscht ist (Spiel verlassen vs. zurück ins Menü).

## Später / Ideen (unpriorisiert)

- Balancing der Produktions-/Lebensdauer-/Erbe-Werte in `worker.gd`
- Sound/Musik
- Mehr Varianz bei Sterbe-Meldungen, ggf. nach Ereignis-Typ statt nur
  Geschlecht/Alterskategorie
