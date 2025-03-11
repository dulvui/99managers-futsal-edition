<!--
SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

SPDX-License-Identifier: CC0-1.0
-->

# Roadmap
List of features/issues of 99 Managers Futsal Edition.  
This file currently serves also as changelog.

# Table of contents
- [Roadmap](#roadmap)
  - [Table of contents](#table-of-contents)
  - [Backlog](#backlog)
  - [In progress](#in-progress)
  - [Done](#done)

# Backlog
Features/issues that will [probably] be added/solved in future.

- In-game editor for player and team
- Visible players' attributes during match
- In the formation screen, visible players' positions their 'squares'.
- Make the players' attributes visible in the formation screen, by clicking on their squares or perhaps by hovering over them.
- For the selection of the starting lineup, first select players in the 'Players' section,
  then you drag the selected players to their positions in the formation screen,
  instead of having the entire squad there.
- When you drag a player into a position, highlight the player's favorite position in the court design.
- Add teams' colors, the top of the screen should be blue and red
- Visualize your squad starting from the base to the tip (Goalkeepers on the top, then D -> C -> W, etc)

# In progress
List of features that are currently worked on.

- Buy and sell players
- Match engine
    - Fouls
        - Yellow and red cards
- Translations
    - French
- Export and import for player and team
- Links to players and teams in emails and news
    - on click, open player/team profile

# Done
Features/issues that are added/solved in specific version.  
This tries to follow the [keepachangelog](https://keepachangelog.com/en/1.1.0/) guideline.

## [0.3.0]
### [Unreleased]

### Added
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

### Changed
- Better match engine
    - Use finite state machines for teams and players

### Security
- Use json over custom resources for save state files to prevent [malicious code execution](https://github.com/godotengine/godot-proposals/issues/4925)
