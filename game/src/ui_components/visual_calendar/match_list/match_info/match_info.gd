# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name MatchInfo
extends HBoxContainer

@onready var home: Label = $Home
@onready var away: Label = $Away
@onready var result: Label = $Result


func setup(matchz: Match) -> void:
	home.text = matchz.home_name
	away.text = matchz.away_name

	if matchz.over:
		result.text = matchz.get_result()

	# make selected team label bold
	ThemeUtil.bold(home, matchz.home_id == Global.team.id)
	ThemeUtil.bold(away, matchz.away_id == Global.team.id)
