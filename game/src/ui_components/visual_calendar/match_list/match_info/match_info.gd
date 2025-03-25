# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name MatchInfo
extends HBoxContainer

@onready var home: Label = $Home
@onready var away: Label = $Away
@onready var result: Label = $Result


func setup(matchz: Match, short_name: bool = false) -> void:
	if short_name:
		home.text = matchz.home.name.substr(0, 3).to_upper()
		home.tooltip_text = matchz.home.name
		away.text = matchz.away.name.substr(0, 3).to_upper()
		away.tooltip_text = matchz.away.name
	else:
		home.text = matchz.home.name
		away.text = matchz.away.name

	if matchz.over:
		result.text = matchz.get_result(true)

	# make selected team label bold
	ThemeUtil.bold(home, matchz.home.id == Global.team.id)
	ThemeUtil.bold(away, matchz.away.id == Global.team.id)
