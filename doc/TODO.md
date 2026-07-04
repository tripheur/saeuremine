# TODO

## Für morgen (kurzfristig)

### 1. Bug: Speicherbutton wird nicht angezeigt
- **Ort:** `scenes/game.tscn`, Node `Game`
- **Ursache gefunden:** `save_button = NodePath("Buybutton")` zeigt auf den
  falschen Node. Der eigentliche `SaveButton`-Node existiert in der Szene
  und ist auch korrekt per Signal (`pressed → _on_save_button_pressed`)
  verbunden – nur die exportierte Variable in `game.gd` verweist noch auf
  `Buybutton`.
- **Fix:** In der Godot-Editor-UI (Inspector des `Game`-Node) das
  `save_button`-Feld neu auf den `SaveButton`-Node zeigen lassen, oder
  direkt in `game.tscn` Zeile ändern zu:
  `save_button = NodePath("SaveButton")`
- **Zusätzlich prüfen:** Ob `SaveButton` durch Anchors/Position eventuell
  visuell mit `Saeure`-Label oder anderen Elementen überlappt – aktuell
  anchors_preset=5 (Center-Top), das könnte je nach Bildschirmbreite mit
  dem Säure-Label kollidieren. Nach dem Node-Path-Fix in Godot testen.

### 2. Bug: Schrift auf Handy zu klein
- **Ursache gefunden:** `project.godot` hat keine `[display]`-Sektion,
  d.h. kein Stretch-Mode gesetzt. Ohne
  `window/stretch/mode="canvas_items"` (oder `viewport`) und eine
  Basisauflösung skaliert Godot die UI nicht an unterschiedliche
  Bildschirmgrößen/-dichten an.
- **Fix:** In Project Settings → Display → Window:
  - `Stretch Mode` auf `canvas_items` (oder `viewport`, je nachdem ob
    Pixel-Perfektion oder reine Skalierung gewünscht ist)
  - `Stretch Aspect` auf `expand` oder `keep`
  - Eine sinnvolle Basisauflösung setzen (z.B. 720×1280 für Hochformat)
- Danach ggf. Font-Größen/Layout nochmal am echten Gerät gegenchecken.

### 3. Feature: Geld statt Säure als Vererbungs-/Kaufwährung
- **Konzept:** Säure wird verkauft → Geld. Geld kauft Upgrades. Familie
  vererbt beim Tod Geld statt Säure.
- **Betroffene Stellen:**
  - `game.gd`: neue Variable `money: int`, Verkaufsmechanik (Button/Rate?
    Säure gegen Geld eintauschen)
  - `worker.gd`: `inheritance` bleibt strukturell gleich, aber die
    Auszahlung in `_on_timer_timeout()` (Zeile mit `acid += w.inheritance`)
    muss auf `money += w.inheritance` umgestellt werden
  - `update_labels()`, `update_buy_button()`: Anzeige/Kaufpreise ggf. auf
    Geld umstellen
  - `save_game()` / `load_game()` in `game.gd`: `money`-Feld ergänzen
  - Offene Designfrage: Verkaufskurs Säure→Geld fix oder variabel
    (Marktschwankungen als weiterer Kapitalismus-Kommentar?)

## Später / Ideen (unpriorisiert)

- Upgrades-System (was kann man mit Geld kaufen außer neue Arbeiter?)
- Balancing der Produktions-/Lebensdauer-/Erbe-Werte in `worker.gd`
- Sound/Musik
- Mehr Varianz bei Sterbe-Meldungen, ggf. nach Ereignis-Typ statt nur
  Geschlecht/Alterskategorie
- APK im Repo: eventuell aus Git raushalten (Git LFS oder .gitignore),
  aktuell liegt ein 24MB Build + Signatur direkt im Repo
