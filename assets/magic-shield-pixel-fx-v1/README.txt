MAGIC SHIELD PIXEL FX v1 - an animated pixel-art shield bubble
===============================================================================

One effect, a shield bubble: grow it in, loop it, flash a hit over it, pop it.
4 animations on transparent sprite sheets at native size (64x64 cells), and a
matching sound effect for up. Free for any game, commercial or not (CC0,
below).

ANIMATIONS
  up           9 frames   519 ms  the bubble grows out of a spark, overshoots,
                                  settles and materialises into the idle
                                  bubble: its last frame is idle's first (plays
                                  once; then play idle)
  idle        16 frames  1280 ms  the bubble shimmers: its rim churns, glints
                                  twinkle inside and motes drift round it
                                  (seamless loop)
  hit          7 frames   382 ms  an overlay: play it once on a second sprite
                                  over the looping idle, at the same centre. A
                                  blow lands on the upper right: the rim there
                                  flares, a shock ring pulses round the bubble
                                  and a few sparks fly (plays once, ends empty)
  pop         10 frames   575 ms  the bubble flashes, cracks and bursts into
                                  motes (plays once, ends empty)

  The frames' pivot is the bubble's centre (0.5, 0.5): put it on the character.
  Play up, then idle on a loop. For a hit, play hit once on a second sprite at
  the same place over the idle (in Godot, a second AnimatedSprite2D with the
  same Sprite Frames); the idle keeps looping under it. To drop the shield,
  play pop in place of idle.

FOLDERS
  sheets/          fx-shield.png (RGBA), its atlas (JSON) and a Godot 4
                   SpriteFrames (.tres). The bubble's glow is a dithered
                   dark-blue halo, for dark backgrounds.
  sheets-no-halo/  fx-shield-clean: the same frames without the halo, for light
                   or busy backgrounds.
  previews/        a GIF of each animation at 4x on a dark background
  recipe/          the Pixelbolt recipes that draw every frame (see MAKE YOUR
                   OWN)
  sounds/          fx-shield-up.wav, for up (see SOUND)
  pieces.json      the animations, frame counts, cell size and lengths

USING THE SHEETS
  Every frame's rectangle and duration (ms) is in the atlas JSON; the sheet is
  a grid of equal cells, left to right, top to bottom. Frames run 40 to 90 ms
  (fast at the start of a one-shot, slower as it settles), 80 ms in the idle
  loop. Scale only by whole numbers (2x, 3x, 4x) with nearest-neighbour
  filtering.
  Godot 4: copy a .tres and the PNG beside it into your project and set an
    AnimatedSprite2D's Sprite Frames to the .tres; the animation names are up,
    idle, hit, pop. For crisp pixels set the node's Texture Filter to Nearest.
  Unity (we tested the files in Godot 4 only): import the PNG as Sprite (2D and
    UI), Sprite Mode Multiple, Filter Mode Point, Compression None; in the
    Sprite Editor use Slice > Grid By Cell Size 64x64 and tick Keep Empty
    Rects, so one-shots keep their empty last frame. That also keeps the spare
    cells at the end of the sheet: use the frames the atlas lists, in its
    order.
  Phaser and PixiJS (untested): the atlas follows TexturePacker's JSON (Hash)
    layout, with each frame's 0-1 pivot (the cell's centre; in pixels under
    points.anchor_px), "animations" as lists of frame names and a "loops" map.
    Build each animation from those lists; neither loader reads the per-frame
    durations.

SOUND
  fx-shield-up.wav goes with up: 519 ms, the same length as the animation.
  Start it on the same tick as up's frame 0. A soft glassy swell grows out of
  the spark and peaks on the overshoot (frame 2), then a warm two-note glass
  ting comes in on frame 7, as the bubble materialises, and has faded by the
  end of frame 8. It doesn't loop: idle, hit and pop have no sound of their
  own.
  The timing assumes each frame plays for its atlas duration, as the Godot
  .tres does. In Phaser give each frame its duration in anims.create, in PixiJS
  use {texture, time} frames, and in Unity key the clip from the atlas's
  durations.
  Mono WAV, 48 kHz, 16-bit, mastered quiet (about -27 LUFS on its loudest 100
  ms) so it sits under music: start at 100 % and mix down rather than adding
  gain.

LICENCE
  CC0 1.0 Universal (public domain dedication): see LICENSE.txt. Use the art
  and the sound in any project, commercial or not, change them, no permission
  needed. Credit isn't required, but it is appreciated:
    "Pixel FX by Skulitom Rivskiy, made with Pixelbolt (github.com/skulitom/Pixelbolt)"

MAKE YOUR OWN
  recipe/ holds the effect as Pixelbolt recipes: fx-shield-bubble.fx.json is
  the idle bubble, and fx-shield.fx.json draws up, hit and pop and reuses the
  bubble's frames (so up ends exactly where idle starts). Change colours or
  sizes, then rebuild with Node 20 or newer, the bubble first, in the recipe
  folder. The colours and the bubble's radius are in both recipes: to recolour
  or resize, change both.
    npx pixelbolt@0.13.0 compile fx-shield-bubble.fx.json --out fx-shield-bubble.pixel.json
    npx pixelbolt@0.13.0 compile fx-shield.fx.json --out fx-shield.pixel.json
    npx pixelbolt@0.13.0 render fx-shield.pixel.json --out fx-shield
  Pixelbolt's own atlas gives each frame's anchor in pixels and the animations
  as objects; if you load it in Phaser or PixiJS, use the 0-1 pivot instead (or
  keep the shipped atlas when only the colours change). The no-halo sheet is
  the same recipes with every look's "halo" removed.

HOW IT WAS MADE (AI DISCLOSURE)
  Made by AI agents with Pixelbolt (MIT). A language model (Anthropic's Claude)
  wrote the recipes from Pixelbolt's shape layers: the shapes' sizes and
  timing, colour ramps, glow and particle settings. Pixelbolt, our MIT-licensed
  pixel-art engine (version 0.13.0), then drew every frame with its own
  algorithms (no machine learning). No image model was used, and nothing was
  traced or sampled from anyone else's art. The idle started from Pixelbolt's
  own shield example (examples/shield.fx.json): its rim, shine and glint
  settings, with our size, an inner glow and diagonal glints; up, hit and pop
  are new. The sound was made by AI agents too: Claude designed it and wrote
  the code that synthesises it from sine tones (a gliding swell and a two-note
  chime) in Python (NumPy and SciPy), timed to the frames. No AI audio model,
  samples or recordings were used.

LINKS
  Pixelbolt (make effects like these from JSON recipes): https://github.com/skulitom/Pixelbolt
  Try it in your browser: https://skulitom.github.io/Pixelbolt/playground/
