import os
import json

sprites_dir = "assets/sprites"

files = os.listdir(sprites_dir)

sprites = []

for file in files:
    if file.endswith(".spr"):
        with open(sprites_dir + os.sep + file) as fh:
            sprites.append(
                {
                    "sprfile": file,
                }
            )


with open(sprites_dir + os.sep + "sprites.json", "w") as f:
    json.dump(sprites, f, indent=2)