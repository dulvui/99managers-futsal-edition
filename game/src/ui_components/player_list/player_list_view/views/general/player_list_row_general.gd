# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerListRowGeneral
extends PlayerListRow

@onready var team: Label = %Team
@onready var positionz: Label = %Position
@onready var prestige: Label = %Prestige
@onready var nation: Label = %Nation
@onready var birth_date: Label = %BirthDate


func setup(player: Player, index: int) -> void:
	super(player, index)

	if player.team.is_empty():
		team.text = tr("Free agent")
	else:	
		team.text = player.team

	positionz.text = Enum.get_position_type_text(player.position.main)
	prestige.text = player.get_prestige_stars()
	nation.text = tr(player.nation)
	birth_date.text = FormatUtil.day(player.birth_date)

