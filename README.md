My first game in Godot! Originally made to learn Godot for Haven.

Soooo

The end goal of this game was a hybrid cooking sim/platformer roguelite. You're a goose that goes and kills enemies to collect food to sell and make money. Unfortunately, I wasn't able to fully finish it before the end of Crescent, and so I'm submitting it in its current state, where you can move around the level and kill enemies by reflecting their bullets with your shield.

Controls:

WAD - move

S - Shield

Tab - Inventory

AI (Claude Code) was used to debug a few of the issues in the code, namely:
- Fixing collision layers so they were correctly set (I accidentally set the render layers instead of collision layers)
- The need to call "call_deferred" for enemies to correctly drop food
