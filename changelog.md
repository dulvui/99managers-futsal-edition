<!--
SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

SPDX-License-Identifier: CC0-1.0
-->

# Changelog
Features/issues that are added/solved in specific versions.  
This tries to follow the [keepachangelog](https://keepachangelog.com/en/1.1.0/) guideline.

The single changes are separated in the following section for better visibility  
**Match Engine** changes from UI to logic during matches  
**UI** changes to the UI outside of the Match Engine
**Data** changes to data related topics like saving/loading or player attributes
**Logic** changes to game logic outside of the Match Engine

# [0.3.2]
## [Unreleased]

## Added
- Match Engine
    - Goalkeeper has own save ball state and moves to best interposing position
    - Walking animation
- UI
    - (Simple) Stadium detail view in dashboard
    - Change date and currency format in settings
    - Show player/team generation progress during game setup
- Data
    - Generate missing attributes for players of custom csv file
    - Free agent players
    - Create better backups and use check-sums to verify save state and setting files

## Changed
- Match Engine
    - Better collision detection
    - Better pass/shoot trajectory detection
- UI
    - Player profile has now tabs: Overview, Transfers, Contract
    - Show loading progress on game load and save
    - Make light theme default
    - Remove secondary backgrounds in dashboard and other ui elements
    - Hide vim mode in settings, until implemented correctly
    - Make automatic input type detection a check button, instead of a option button
- Data
    - Realistic contract start and end dates
    - Remove data compression ability, all data is readable json/csv files now
- Logic
    - Better data validation when starting new game

## Fixed
- Match Engine
    - Goalkeeper stays in position during penalty and doesn't always go left
    - Show player's hair, eye and skin color again
- Data
    - Faster loading/saving of game data by saving matches as csv
    - Save and load all players data like contract and statistics
- Logic
    - Fixed issues in seasonal finances calculation
    - Reset default settings resets all possible settings

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

