# Game texture assets

Use `generate_image` to create a square tileable texture matching the game's
style, with even lighting, no perspective, and edges designed to repeat. Upload
references through `media_upload` and `media_confirm` when needed. Inspect a
repeated grid of the result before using it; do not claim mathematical seamlessness
from image generation alone.

This review package does not contain `pipeline.py` or `seamless.py`. Do not fetch
or execute external copies, and do not claim these scripts ship with this skill.
The deterministic seam-fix, palette-transfer and PBR-map pipeline is unavailable
in this package. If the task requires those guarantees, report that limitation.
For a 2D game, use inspected generated textures, native CSS/canvas patterns or
existing project assets. Preserve the source image and distinguish inspected
results from unverified properties.
