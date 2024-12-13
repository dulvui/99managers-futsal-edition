# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends Node

enum PlayerNames { MALE, FEMALE, MIXED }

const FONT_SIZE_DEFAULT: int = 18
const FONT_SIZE_MIN: int = 14
const FONT_SIZE_MAX: int = 26

const SCALE_1: float = 0.75
const SCALE_2: float = 1.0
const SCALE_3: float = 1.50

# match engine
const HALF_TIME_SECONDS: int = 60 * 20
const FULL_TIME_SECONDS: int = HALF_TIME_SECONDS * 2
const TICKS_PER_SECOND: int = 4
const SPEED: int = 2
# stamina range [0, 1]
# this factor makes sure a player with attribute stamina 20
# can play a full game running all the time
const STAMINA_FACTOR: float = 1.0 / (HALF_TIME_SECONDS * 2 * TICKS_PER_SECOND)

const MAX_PRESTIGE: int = 20

const LINEUP_PLAYERS_AMOUNT: int = 12

# season start at 1st of june
const SEASON_START_DAY: int = 1
const SEASON_START_MONTH: int = 6

const USER_PATH: StringName = "user://"
const SAVE_STATES_DIR: StringName = "save_states/"
const SAVE_STATES_PATH: StringName = "user://save_states/"

# STRINGS
const MONTH_STRINGS: Array[StringName] = [
	"JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"
]
const WEEKDAYS: Array[StringName] = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
const SURNAME: StringName = "SURNAME"
const POSITION: StringName = "POSITION"

const CUSTOM_PROPERTY: int = 4096
const CUSTOM_PROPERTY_EXPORT: int = 4102

# screens
const SCREEN_MENU: StringName = "res://src/screens/menu/menu.tscn"
const SCREEN_SETTINGS: StringName = "res://src/screens/settings/settings.tscn"
const SCREEN_DASHBOARD: StringName = "res://src/screens/dashboard/dashboard.tscn"
const SCREEN_SETUP_TEAM: StringName = "res://src/screens/setup/setup_team/setup_team.tscn"
const SCREEN_SETUP_WORLD: StringName = "res://src/screens/setup/setup_world/setup_world.tscn"
const SCREEN_SETUP_MANAGER: StringName = "res://src/screens/setup/setup_manager/setup_manager.tscn"
const SCREEN_SETUP_LANGUAGE: StringName = "res://src/screens/setup_language/setup_language.tscn"
const SCREEN_MATCH: StringName = "res://src/screens/match/match.tscn"
const SCREEN_SAVE_STATES: StringName = "res://src/screens/save_states_screen/save_states_screen.tscn"
# scenes
const SCENE_SAVE_STATE_ENTRY: StringName = "res://src/screens/save_states_screen/save_state_entry/save_state_entry.tscn"
