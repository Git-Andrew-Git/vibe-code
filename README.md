# Alien Ocean Survival (Working Title)

> **2D Singleplayer Open-World Survival & Crafting Game**  
> Set on a high-fidelity alien water world. High-quality 4K visual assets, dynamic music/ambience, deep crafting, and story-driven discovery.

---

## Technical Specs

- **Engine:** Godot 4.x
- **Target Native Resolution:** `1920×1080` (Downsampled from 4K source assets, scaled with aspect lock)
- **Primary Language:** GDScript 2.0
- **Primary Platform:** PC (Windows / Linux / macOS)

---

## Repository Layout

```
.
├── assets/             # Raw / source assets (sprites, tilesets, audio, fonts, shaders)
├── docs/               # GDD, story bible, art bible, audio bible, roadmap
├── res/                # Godot scenes, scripts, prefabs, materials, singletons
│   ├── autoloads/      # Global state & service singletons
│   ├── materials/
│   ├── prefabs/
│   ├── scenes/
│   └── scripts/
├── tests/              # Automated unit tests (GUT / gdUnit)
├── tools/              # CI, export, asset validation tools
├── project.godot       # Main Godot project configuration
└── README.md
```

---

## Development Setup

1. Install **Godot Engine 4.x** (Standard or .NET edition).
2. Clone this repository.
3. Open Godot and click **Import**, then select `project.godot`.
4. Press `F5` to run the project (Main scene: `res/scenes/Main.tscn`).

---

## Code Style & Standards

- Follow standard **GDScript 2.0** conventions (tabs for indentation, PascalCase for classes/scenes, snake_case for functions/variables).
- Enforced via `.editorconfig`.
