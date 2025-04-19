<!--
SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

SPDX-License-Identifier: CC0-1.0
-->

# Changelog
Features/issues that are added/solved in specific versions.  
This tries to follow the [keepachangelog](https://keepachangelog.com/en/1.1.0/) guideline.
# [0.3.2]
## [Unreleased]

## Added
- Generate missing attributes for players of custom csv file
- (Simple) Stadium detail view in dashboard
- Changee date and currency format in settings
- Free agent players

## Changed
- Better data validation when starting new game
- Player profile has now tabs: Overview, Transfers, Contract
- Realistic contract start and end dates

## Fixed
- Fixed issues in seasonal finances calculation
- Faster loading/saving of game data by saving matches as csv
- Show player's hair, eye and skin color again
- Save and load all players data like contract and statistics

## Contributors
- Simon Dalvai

# [0.3.1]
## https://codeberg.org/dulvui/99managers-futsal-edition/releases/tag/v0.3.1

## Added
- Player properties and attributes can be defined in custom csv file
- Backup for csv files
- Automated shirt number assignment

## Changed
- Teams are now starting in the league defined in the starting csv file, after history generation

## Contributors
- Simon Dalvai

# [0.3.0]
## https://codeberg.org/dulvui/99managers-futsal-edition/releases/tag/v0.3.0

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
- UI restyling

## Changed
- Better match engine
    - Use finite state machines for teams and players

## Security
- Use json over custom resources for save state files to prevent [malicious code execution](https://github.com/godotengine/godot-proposals/issues/4925)

## Contributors
- Simon Dalvai

