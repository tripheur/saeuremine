# Säuremine-Sim

Ein kapitalismuskritischer Idle/Clicker gebaut in Godot 4.3.

Du verwaltest eine Säuremine mit deiner (zufällig generierten) Familie als
Arbeitskräften. Familienmitglieder schuften, altern, sterben irgendwann an
der Arbeit – und vererben dir dabei Geld, mit der du weitere Familie
"rekrutieren" kannst. Bis die Familie aufgebraucht ist.

## Aktueller Stand

Spielbar, aber noch nicht rund:

- Grundschleife funktioniert: klicken, Säure gegen Geld verkaufen, Arbeiter
  kaufen, Arbeiter produzieren automatisch über einen Timer, altern,
  sterben, vererben Geld, Game Over wenn die Familie erschöpft ist.
- Zwei-Währungen-System: Säure wird erarbeitet und über einen
  Verkaufen-Button gegen Geld eingetauscht; Geld kauft Arbeiter (und
  demnächst Upgrades). Kaufen-/Verkaufen-Button grauen automatisch aus,
  wenn nicht genug Geld bzw. Säure vorhanden ist.
- Highscore-System (`SaveManager`) speichert `total_acid` / `total_money` /
  `total_deaths` / `family_name` persistent.
- Spielstand-Speichern (`save_game()` / `load_game()`) ist implementiert,
  inklusive Geld.
- Speichern-Button und Schriftskalierung auf Mobilgeräten sind gefixt,
  siehe [CHANGELOG.md](./CHANGELOG.md).
- Android-Export ist eingerichtet (`export_presets.cfg`), ein Build liegt
  im Repo (`saeuremine-sim/saueremine.apk`).
- Upgrades-Button ist in der UI vorhanden, aber noch ohne Funktion
  (Popup fehlt noch), siehe TODO.

## Projektstruktur

```
saeuremine-sim/
├── project.godot
├── export_presets.cfg
├── scenes/
│   ├── main_menu.tscn
│   ├── game.tscn
│   └── game_over.tscn
└── scripts/
    ├── global.gd        # Autoload, hält Übergabedaten zwischen Szenen
    ├── save_manager.gd  # Autoload, Speicherstand + Highscore (JSON in user://)
    ├── game.gd          # Kernlogik: Familie generieren, Arbeit, Kauf, Timer-Tick, Save/Load
    ├── worker.gd        # Resource-Klasse für Arbeiter (Adult/Retiree/Child)
    ├── main_menu.gd
    └── game_over.gd
```

## Spielmechanik (Kurzfassung)

- Drei Arbeiter-Typen mit unterschiedlicher Produktion, Lebensdauer und
  Erbe: `ADULT` (2/60s/30), `RETIREE` (1/30s/50), `CHILD` (3/20s/10)
  (siehe `worker.gd`).
- Familienpool wird beim ersten Start zufällig generiert (3–30 Mitglieder,
  deutsche Verwandtschaftsbezeichnungen + Namen nach Alterskategorie).
- Säure wird durch Klicken und durch aktive Arbeiter erarbeitet und lässt
  sich über den Verkaufen-Button gegen Geld eintauschen (Kurs aktuell fix
  1:1, siehe `acid_cost` in `game.gd`).
- Rekrutieren kostet Geld, Kosten steigen um 10 % pro Kauf.
- Beim Ableben eines Arbeiters gibt es eine zufällige, morbide Sterbe-Meldung
  im Log plus eine Geld-"Erbschaft".

## Changelog

Siehe [CHANGELOG.md](./CHANGELOG.md).

## Bekannte Baustellen

Siehe [TODO.md](./doc/TODO.md) für die priorisierte Liste.

## Setup

Öffnen mit Godot 4.3 (`saeuremine-sim/project.godot`). Für Android-Export
sind die Presets bereits hinterlegt, siehe `export_presets.cfg`.

## Lizenz

MIT, siehe [LICENSE](./LICENSE).
