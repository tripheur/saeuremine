# TODO

## Offene Punkte

### 1. Feature: Upgrades fertig machen (erledigt)

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

### 3. Feature: Auswahl, welches Familienmitglied in die Mine geschickt wird (erledigt)

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
- **Umzusetzen:** Ein Popup-Fenster öffnet sich und sagt "Spielstand gespeichert. Möchten Sie zum Hauptmenu zurückkehren?" Ja/Nein

5. Story-Mode

* Startseite zur Auswahl des Charakternamens und Geschlechts.
* kurze Spieleinführung: Du bist [Spielername]. Vor kurzem bist du in den Besitz einer Säuremine gelangt. Die Arbeitsbedingungen sind hart und gefährlich. Niemand will für dich arbeiten....
* Dann selber schuften, bis man 100 € verdient hat. (Lebensbalken sinkt langsam)
* Vorstellung der Familie: Das sind deine Familienmitglieder. [Random ausgewähltes Familienmitglied] bittet dich, ihm/ ihr 100 Euro zu leihen. Da kommt dir eine Idee: Familienmitglied in die Mine schicken/ Gib die 100 € ohne Gegenleistung.
* Du schickst Familienmitglied in die Mine und es arbeitet fleißig, bis es stirbt und du erbst. Daraufhin wird weitere Mitglieder in die Mine schicken freigeschaltet.
* Wenn du 1000 Euro erspielt hast, werden die Upgrades freigeschaltet.
* Wenn alle Familienmitglieder tot sind, musst du wieder selbst schuften. Wenn dein Lebensbalken leer ist, ist das Spiel zu Ende. Am Ende wird aufgerechnet (basierend auf der Zahl deiner Familienmitglieder - wieviel Geld du mit ihrem Tot verdient hast und ob du jetzt im Jenseits büßen musst.


### 5. Ergänzung weitere Upgrades für positives Karma

- **Kontext:** Bisher kann man nur negatives Karma sammeln. Man landet also unweigerlich in der Hölle.
- **Umzusetzen:** Daher 2 Arten von Upgrades für positives Karma: 1. Upgrades von Selber Schuften (wird effizienter und bessere Lebensregeneration). 2. Charity (Upgrades die sehr teuer sind und außer gutem Karma nichts bringen, z.B. Spende ans Tierheim oder Finanzieren von Ferienlagern für Kinder.



### 6. Balancing Lebensregeneration

- **Kontext:** Sobald Lebensregeneration im Spiel ist, wird das Spiel zu einfach (man muss nie sterben)
- **Umzusetzen:** Einführen einer Mechanik, die dafür sorgt, das man immer mehr Säure abbauen muss. Wenn man keine Arbeiter mehr bezahlen kann muss man selber immer härter arbeiten und stirbt. Brainstorming ob der korrekten Spielmechanik.

## Später / Ideen (unpriorisiert)

- Balancing der Produktions-/Lebensdauer-/Erbe-Werte in `worker.gd`
- Sound/Musik
- Mehr Varianz bei Sterbe-Meldungen, ggf. nach Ereignis-Typ statt nur
  Geschlecht/Alterskategorie
