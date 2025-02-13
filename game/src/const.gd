# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends Node

#
# UI
#
const FONT_SIZE_DEFAULT: int = 18
const FONT_SIZE_MIN: int = 14
const FONT_SIZE_MAX: int = 26

const SCALE_1: float = 0.75
const SCALE_2: float = 1.0
const SCALE_3: float = 1.50

#
# Match Engine
#
const HALF_TIME_SECONDS: int = 60 * 20
const FULL_TIME_SECONDS: int = HALF_TIME_SECONDS * 2
const OVER_TIME_SECONDS: int = FULL_TIME_SECONDS + (60 * 5)
const FULL_OVER_TIME_SECONDS: int = OVER_TIME_SECONDS + (60 * 5)

const PENALTY_KICKS: int = 5

# how many ticks pass per real match second
# used for ball movents, colissions ecc...
const TICKS: int = 32
# used for state machine updates, player movements ecc...
# is always relative to TICKS
const TICKS_LOGIC: int = TICKS / 4

const SPEED: float = 0.5

# stamina range [0, 1]
# this factor makes sure a player with attribute stamina 20
# can play a full game running all the time
const STAMINA_FACTOR: float = 1.0 / (FULL_TIME_SECONDS * TICKS_LOGIC * 20) # 20 = max player speed

#
# Generator
#
const MAX_PRESTIGE: int = 20

const LINEUP_PLAYERS_AMOUNT: int = 12

# season start at 1st of june
const SEASON_START_DAY: int = 1
const SEASON_START_MONTH: int = 6


# Strings
#
const USER_PATH: StringName = "user://"
const SAVE_STATES_DIR: StringName = "save_states/"
const SAVE_STATES_PATH: StringName = "user://save_states/"

const SURNAME: StringName = "Surname"
const POSITION: StringName = "Postition"

# screens
const SCREEN_MENU: String = "res://src/screens/menu/menu.tscn"
const SCREEN_SETTINGS: String = "res://src/screens/settings/settings.tscn"
const SCREEN_DASHBOARD: String = "res://src/screens/dashboard/dashboard.tscn"
const SCREEN_SETUP_TEAM: String = "res://src/screens/setup/setup_team/setup_team.tscn"
const SCREEN_SETUP_WORLD: String = "res://src/screens/setup/setup_world/setup_world.tscn"
const SCREEN_SETUP_LANGUAGE: String = "res://src/screens/setup/setup_language/setup_language.tscn"
const SCREEN_MATCH: String = "res://src/screens/match_screen/match_screen.tscn"
const SCREEN_SAVE_STATES: String = "res://src/screens/save_states_screen/save_states_screen.tscn"
# scenes
const SCENE_SAVE_STATE_ENTRY: String = "res://src/screens/save_states_screen/save_state_entry/save_state_entry.tscn"
# ui components
const SCENE_COLOR_LABEL: String = "res://src/ui_components/base/color_label/color_label.tscn"
const SCENE_PLAYER_LIST_COLUMN: String = "res://src/ui_components/player_list/player_list_column/player_list_column.tscn"
const SCENE_FORMATION_PLAYER: String = "res://src/ui_components/visual_formation/player/formation_player.tscn"

#
# Property access
#
const CUSTOM_PROPERTY: int = 4096
const CUSTOM_PROPERTY_EXPORT: int = 4102

