<!--
SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

SPDX-License-Identifier: CC0-1.0
-->

# 99 Managers® Futsal Edition
A futsal manager game created with the Godot Engine.  
**[Wishlist now on Steam!](https://store.steampowered.com/app/3334770/99_Managers_Futsal_Edition/)**  
**[Play the beta on itch.io](https://simondalvai.itch.io/99managers-futsal-edition)**

Join [Matrix](https://matrix.to/#/%23s9i.org:matrix.org) or [Discord](https://discord.gg/a5DSHZKkA8) if you have questions and want to stay updated.

# Repositories and issue tracker
The main repository is on [Codeberg](https://codeberg.org/dulvui/99managers-futsal-edition),
which is where the issue tracker may be found and where contributions are accepted.
A read-only mirror exists on [Github](https://github.com/dulvui/99managers-futsal-edition).  
Note: You can use your Github account to sign in on Codeberg.

The idea of mirroring a Codeberg repository to other git platforms was inspired by [riverwm](https://codeberg.org/river/river).

All issues from the Codeberg issue tracker and other sources like e-mail or forums, are listed in the [issues.md](/issues.md) file.

# Translations
If you would like to add more languages or want to improve existing, you can do so on [Weblate](https://hosted.weblate.org/engage/99-managers-futsal-edition/).  
Weblate is an Open Source translation tool and has a very generous free offering for Open Source projects like this one.  
Thanks a lot Weblate!

<a href="https://hosted.weblate.org/engage/99-managers-futsal-edition/">
<img src="https://hosted.weblate.org/widget/99-managers-futsal-edition/game/287x66-white.png" alt="Translation status" />
</a>

# FAQ
Check out my blog post for frequently asked questions about the game.  
[simondalvai.org/blog/futsal-manager-faq/](https://simondalvai.org/blog/99managers-futsal-faq/)

# Development
This game is developed using the [Godot Engine](https://godotengine.org/) version 4.x.
The exact version used can be found in the [project.godot](game/project.godot) under `config/features`.
```c
config/features=PackedStringArray("4.4")
```
Download the exact version used from the [Godot Engine website](https://godotengine.org/) and open the project.  
Please follow Godot's official [GDScript style guide](https://docs.godotengine.org/en/latest/tutorials/scripting/gdscript/gdscript_styleguide.html)
and [best practices](https://docs.godotengine.org/en/stable/tutorials/best_practices/index.html),
if contributing to this codebase.

# Build
The game can be built following the official Godot export
[documentation](https://docs.godotengine.org/en/stable/tutorials/export/exporting_projects.html).  
For automated builds, there is a [build script](scripts/build/build.sh) that creates executables for Linux, Windows and MacOS.
The final output will be located in the `builds` directory as a single zip archive for every platform and a directory with the executables.  
Note: This script is targeted to work on **Linux**, but it might work also on other operating systems, with minor changes.

## export_preset.cfg
To export a project to a given platform, a
[configuration file](https://docs.godotengine.org/en/latest/tutorials/export/exporting_projects.html#configuration-files)
named `export_presets.cfg` is needed.
Follow the official Godot export [documentation](https://docs.godotengine.org/en/stable/tutorials/export/exporting_projects.html)
if you want to build using the editor on your machine.

For automated script, like described in the next section, the pre-defined files located in the game directory are used.
You can take a look at them and adapt the configuration to your needs.  
As an example here you can find the [Linux configuration](game/export_presets.linux.example).
The configuration for other platforms are named `export_presets.[platform_name].example`.

## Automated script
The script uses environment variables for paths, passwords.  
It will download the Godot executable, if `GODOT_PATH` is not set and no executable was found.
The same happens for the [export templates](https://docs.godotengine.org/en/latest/tutorials/export/exporting_projects.html#export-templates),
if the templates for the used version are not found in `~/.local/godot/share/export_templates/`.  
Note: This makes the script ready to be used on automated CI servers.
Just make sure to **cache** the Godot executable and export templates (more than 1GB) to **save bandwidth, time and energy**.

The following steps are needed to run the script.
This steps can be replaced by another script, if used on CI servers.
1) Copy the example file.
```bash
cp scripts/build/.env.example scripts/build/.env
```
2) Fill it with your configuration.
```bash
# version of godot used
GODOT_VERSION=
# path to your godot executable
# the script will download the executable, if left empty
GODOT_PATH=
# name of the game
GAME_NAME=
# path to the directory containing the project.godot file
GAME_PATH=
```
3) Run the script
```bash
cd scripts/build/
bash build.sh
```

# Changelog
A detailed changelog of every version can be found in the [changelog.md](/changelog.md) file.  
It can also be found in the game from the menu under About -> Changelog.

# Licenses and copyrights
All source code is licensed under [AGPLv3](LICENSES/AGPL-3.0-or-later.txt)  
All assets made by me, are licensed under [CC BY-SA 4.0](LICENSES/CC-BY-SA-4.0.txt)

This project uses the [FSFE reuse tool](https://github.com/fsfe/reuse-tool) to license files.  
Check out all licenses and copyrights holders [here](REUSE.toml).  
The corresponding full license texts can be found in the [LICENSES/](./LICENSES/) directory.

