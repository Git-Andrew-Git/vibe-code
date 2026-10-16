# Art Bible & Visual Standards

## Visual Target
- **Art Style:** High-detail 2D hand-drawn with vector precision and soft dynamic lighting.
- **Color Palette:** Deep teals, bioluminescent cyans, magenta accents for flora, warm amber for player structures.
- **Source Canvas:** All source art drawn at **4K resolution (3840×2160 background canvases, 512×512 to 2048×2048 sprite sheets)**.
- **In-Engine Resolution:** Scaled to 1920×1080 native project resolution with `canvas_items` stretch and `Linear` texture filtering with mipmaps enabled to look crisp on 4K monitors without performance drops.

## Asset Pipeline
- **Sprites & Textures:** Exported as PNG with alpha channel.
- **Tilemaps:** 128×128 tile size (4K master at 512×512).
- **Shaders:** Custom 2D water caustic shader, refractive wave distortion, bioluminescent pulsing.
