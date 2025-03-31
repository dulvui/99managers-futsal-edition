# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name CSVHeaders

const WORLD: PackedStringArray = [
	"continent",
	"nation",
	"league",
]

const TEAM: PackedStringArray = [
	"team name",
	"budget",
	"stadium name",
	"stadium capacity",
]

const PLAYER: PackedStringArray = [
	"name",
	"surname",
	"birth_date",
	"nationality",
	"shirt number",
	"preferred foot",
	"main position",
	"alt positions",
	"injury prone",
	"eye color",
	"hair color",
	"skintone color",
]

const PLAYER_ATTRIBUTES_GOALKEEPER: PackedStringArray = [
	"reflexes",
	"positioning",
	"save_feet",
	"save_hands",
	"diving",
]

const PLAYER_ATTRIBUTES_MENTAL: PackedStringArray = [
	"aggression",
	"anticipation",
	"decisions",
	"concentration",
	"vision",
	"workrate",
	"marking",
]

const PLAYER_ATTRIBUTES_PHYSICAL: PackedStringArray = [
	"pace",
	"acceleration",
	"stamina",
	"strength",
	"agility",
	"jump",
]

const PLAYER_ATTRIBUTES_TECHNICAL: PackedStringArray = [
	"crossing",
	"passing",
	"long_passing",
	"tackling",
	"heading",
	"interception",
	"shooting",
	"long_shooting",
	"free_kick",
	"penalty",
	"finishing",
	"dribbling",
	"blocking",
]

#,
# only for internal use like save states
#
const WORLD_INTERNAL: PackedStringArray = [
	"continent_code",
	"nation_code",
	"competition_id",
	"team_id",
	"player_id",
]

const COMPETITION: PackedStringArray = [
	"name",
	"nation_code",
	"pyramid_level",
	"price_money",
]

const HISTORY_COMPETITION: PackedStringArray = [
]

const MATCH: PackedStringArray = [
]

const EMAIL: PackedStringArray = [
]

const TRANSFERS: PackedStringArray = [
]

