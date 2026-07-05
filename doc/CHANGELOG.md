# Changelog

Alle nennenswerten Änderungen an Säuremine-Sim werden hier dokumentiert.

## [0.2] - 2026-07-05

### Hinzugefügt
- Geld-System: Säure lässt sich über einen Verkaufen-Button gegen Geld
  eintauschen (Kurs aktuell fix 1:1, siehe `acid_cost` in `game.gd`)
- Arbeiter kosten jetzt Geld statt Säure beim Rekrutieren
- Kaufen- und Verkaufen-Button grauen automatisch aus, wenn nicht genug
  Geld bzw. Säure vorhanden ist
- Game-Over-Screen und Highscore zeigen jetzt auch verdientes Geld an

### Geändert
- Vererbung beim Tod eines Arbeiters zahlt jetzt Geld statt Säure aus
- Spielstand (Speichern/Laden) umfasst jetzt Geld und Geld-Gesamtsumme

### Behoben
- Speichern-Button hat nicht reagiert – die exportierte `save_button`-Variable
  in `game.gd` zeigte auf den falschen Node (`Buybutton` statt `SaveButton`)
- Schrift war auf Mobilgeräten zu klein, da kein Stretch-Mode gesetzt war

## [0.1] - Erste spielbare Version

- Grundschleife: Familie generieren, klicken, Arbeiter kaufen, automatische
  Produktion per Timer, Altern, Sterben, Vererbung (Säure), Game Over bei
  erschöpfter Familie
- Highscore-System (`SaveManager`)
- Speichern/Laden des Spielstands
- Android-Export eingerichtet
