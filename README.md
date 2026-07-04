# Säuremine-Sim

Ein kapitalismuskritischer Idle/Clicker gebaut in Godot 4.3.

Du verwaltest eine Säuremine mit deiner (zufällig generierten) Familie als
Arbeitskräften. Familienmitglieder schuften, altern, sterben irgendwann an
der Arbeit – und vererben dir dabei Säure, mit der du weitere Familie
"rekrutieren" kannst. Bis die Familie aufgebraucht ist.

## Aktueller Stand

Spielbar, aber noch nicht rund:

- Grundschleife funktioniert: klicken, Arbeiter kaufen, Arbeiter produzieren
  automatisch über einen Timer, altern, sterben, vererben Säure, Game Over
  wenn die Familie erschöpft ist.
- Highscore-System (`SaveManager`) speichert `total_acid` / `total_deaths` /
  `family_name` persistent.
- Spielstand-Speichern (`save_game()` / `load_game()`) ist implementiert.
- Android-Export ist eingerichtet (`export_presets.cfg`), ein Build liegt
  im Repo (`saeuremine-sim/saueremine.apk`).
- UI ist funktional, aber nicht responsive/skaliert nicht für Mobilgeräte,
  siehe TODO.

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
- Rekrutieren kostet Säure, Kosten steigen um 10 % pro Kauf.
- Beim Ableben eines Arbeiters gibt es eine zufällige, morbide Sterbe-Meldung
  im Log plus eine Säure-"Erbschaft".

## Bekannte Baustellen

Siehe [TODO.md](./doc/TODO.md) für die priorisierte Liste.

## Setup

Öffnen mit Godot 4.3 (`saeuremine-sim/project.godot`). Für Android-Export
sind die Presets bereits hinterlegt, siehe `export_presets.cfg`.
