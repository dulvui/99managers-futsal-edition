# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends Node

enum PlayerNames {
	MALE,
	FEMALE,
	MIXED,
}

enum MatchSpeed {
	FULL_GAME,
	KEY_ACTIONS,
	ONLY_GOALS,
}

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

const TICKS_PER_SECOND: int = 32
# state machines update every half second
const STATE_UPDATE_TICKS: int = min(2, TICKS_PER_SECOND / 2.0)

const SPEED: float = (1.0 / TICKS_PER_SECOND) * 8.0
# stamina range [0, 1]
# this factor makes sure a player with attribute stamina 20
# can play a full game running all the time
const STAMINA_FACTOR: float = 1.0 / (HALF_TIME_SECONDS * 2 * TICKS_PER_SECOND * 20) # 20 = max player speed

#
# Generator
#
const MAX_PRESTIGE: int = 20

const LINEUP_PLAYERS_AMOUNT: int = 12

# season start at 1st of june
const SEASON_START_DAY: int = 1
const SEASON_START_MONTH: int = 6

#
# Strings
#
const USER_PATH: StringName = "user://"
const SAVE_STATES_DIR: StringName = "save_states/"
const SAVE_STATES_PATH: StringName = "user://save_states/"

const MONTH_STRINGS: Array[StringName] = [
	"JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"
]
const WEEKDAYS: Array[StringName] = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
const SURNAME: StringName = "SURNAME"
const POSITION: StringName = "POSITION"

# screens
const SCREEN_MENU: String = "res://src/screens/menu/menu.tscn"
const SCREEN_SETTINGS: String = "res://src/screens/settings/settings.tscn"
const SCREEN_DASHBOARD: String = "res://src/screens/dashboard/dashboard.tscn"
const SCREEN_SETUP_TEAM: String = "res://src/screens/setup/setup_team/setup_team.tscn"
const SCREEN_SETUP_WORLD: String = "res://src/screens/setup/setup_world/setup_world.tscn"
const SCREEN_SETUP_MANAGER: String = "res://src/screens/setup/setup_manager/setup_manager.tscn"
const SCREEN_SETUP_LANGUAGE: String = "res://src/screens/setup/setup_language/setup_language.tscn"
const SCREEN_MATCH: String = "res://src/screens/match/match.tscn"
const SCREEN_SAVE_STATES: String = "res://src/screens/save_states_screen/save_states_screen.tscn"
# scenes
const SCENE_SAVE_STATE_ENTRY: String = "res://src/screens/save_states_screen/save_state_entry/save_state_entry.tscn"
# ui components
const SCENE_COLOR_LABEL: String = "res://src/ui_components/base/color_label/color_label.tscn"
const SCENE_PLAYER_LIST_COLUMN: String = "res://src/ui_components/player_list/player_list_column/player_list_column.tscn"

#
# Property access
#
const CUSTOM_PROPERTY: int = 4096
const CUSTOM_PROPERTY_EXPORT: int = 4102
