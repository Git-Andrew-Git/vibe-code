# Project Roadmap & Milestones

## M0 — Initial Architecture (COMPLETE)
- [x] Project structure and directories created
- [x] `project.godot` configured (1920×1080 default, Forward+ renderer, canvas_items scaling)
- [x] Core autoload singletons (`EventBus`, `GameState`, `AudioManager`)
- [x] Boot scene (`Main.tscn` + `Main.gd`) with HUD display
- [x] Core design documentation (GDD, Story, Art Bible, Audio Bible)

## M1 — Character Controller & Basic Water Physics (COMPLETE)
- [x] 2D Top-down / 8-directional player movement
- [x] Swimming vs. walking state machine
- [x] Camera follow with smooth drag & viewport bounds

## M2 — TileMap World & Water Shaders (COMPLETE)
- [x] TileMapLayer setup for shallows, sand, deep water
- [x] 2D Animated Water Caustics shader
- [x] Day/Night visual tone-mapping (CanvasModulate)

## M3 — Survival Stats & Inventory System
- [ ] Oxygen meter + underwater depletion logic
- [ ] Items resource schema (`.tres`)
- [ ] Inventory grid UI + Hotbar
- [ ] Crafting recipe engine

## M4 — Ecosystem (Flora & Fauna)
- [ ] Harvestable kelp and coral nodes
- [ ] Passive alien fish pathfinding (Flocking / Wandering)
- [ ] Aggressive fauna AI state machine

## M5 — Story Audio & Narrative UI
- [ ] Dialogue window system
- [ ] Ambient water audio loop + adaptive music trigger
- [ ] Story log / PDA interface
