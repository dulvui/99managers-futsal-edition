# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name CSVHeaders

const BASE: PackedStringArray = [
	"nation [iso code]",
	"league name",
	"team name",
	"budget [0, 999_999_999]",
	"stadium name",
	"stadium capacity [200, 20_000]",
	"stadium construction year [yyyy]",
	"player first name",
	"player surname",
	"value [€, $,...]",
	"birth_date [dd/mm/yyyy]",
	"nationality [iso code]",
	"shirt number [1, 99]",
	"foot left [1, 20]",
	"foot right [1, 20]",
	"main position [G, D, P...]",
	"alt positions [\"D,C,P\"]",
	"injury prone [1, 20]",
	"eye color [\"hex\"]",
	"hair color [\"hex\"]",
	"skintone color [\"hex\"]",
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
	"offensive_movement",
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


var size: int
var attributes_start: int
var list: PackedStringArray


func _init() -> void:
	size = BASE.size()

	attributes_start = size
	
	size += PLAYER_ATTRIBUTES_GOALKEEPER.size() + PLAYER_ATTRIBUTES_MENTAL.size()
	size += PLAYER_ATTRIBUTES_PHYSICAL.size() + PLAYER_ATTRIBUTES_TECHNICAL.size()

	list = PackedStringArray()
	list.append_array(BASE)
	list.append_array(PLAYER_ATTRIBUTES_GOALKEEPER)
	list.append_array(PLAYER_ATTRIBUTES_MENTAL)
	list.append_array(PLAYER_ATTRIBUTES_PHYSICAL)
	list.append_array(PLAYER_ATTRIBUTES_TECHNICAL)

