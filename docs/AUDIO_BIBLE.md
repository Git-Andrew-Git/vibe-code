# Audio Bible & Sound Design

## Aesthetic
An immersive hybrid of organic environmental field recordings, wet synth pads, sub-bass rumbles, and delicate crystalline melodies.

## Dynamic Music System
- **Base Layer:** Atmospheric ambient pad (always playing, volume responds to depth/zone).
- **Secondary Layer:** Rhythmic percussion / synth pulse (fades in when exploring new ruins or in danger).
- **Stems Strategy:**
  - `music_base_shallows.ogg`
  - `music_deep_trench.ogg`
  - `ambience_water_surface.ogg`
  - `ambience_underwater_deep.ogg`

## Audio Buses Setup
1. **Master**
   ├── **Music** (Dynamic crossfading)
   ├── **Ambience** (Environmental loops)
   └── **SFX** (UI, player movement, swimming, crafting, creatures)
