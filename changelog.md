<!--
SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

SPDX-License-Identifier: CC0-1.0
-->

# Changelog
Features/issues that are added/solved in specific versions.  
This tries to follow the [keepachangelog](https://keepachangelog.com/en/1.1.0/) guideline.

# [0.3.0]
## [Unreleased]

## Added
- Custom csv files can be used during setup
- Translations
    - Spanish
    - Portuguese
- Add a futsal court design when selecting your starting lineup showing where each position is located.
- Match engine
    - Fouls
        - Free kicks
        - Penalties
        - Penalties (10m) after 6 fouls

## Changed
- Better match engine
    - Use finite state machines for teams and players

## Security
- Use json over custom resources for save state files to prevent [malicious code execution](https://github.com/godotengine/godot-proposals/issues/4925)
