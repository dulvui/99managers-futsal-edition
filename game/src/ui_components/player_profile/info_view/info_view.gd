# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name InfoView
extends GridContainer


@onready var player_name: Label = %Name
@onready var pos: Label = %Position
@onready var alt_pos: Label = %AltPosition
@onready var age: Label = %Age
@onready var foot: Label = %Foot
@onready var nationality: Label = %Nationality
@onready var team: Label = %Team
@onready var nr: Label = %Nr
@onready var attributes_average: Label = %AttributesAverage
@onready var prestige: Label = %Prestige
@onready var value: Label = %Value


func setup(player: Player) -> void:
	player_name.text = player.name + " " + player.surname
	pos.text = str(Position.Type.keys()[player.position.type])
	alt_pos.text = str(
		player.alt_positions.map(func(p: Position) -> String: return Position.Type.keys()[p.type])
	)

	age.text = (
		str(player.birth_date.day)
		+ "/"
		+ str(player.birth_date.month)
		+ "/"
		+ str(player.birth_date.year)
	)
	foot.text = Player.Foot.keys()[player.foot]
	nationality.text = str(player.team)
	team.text = str(player.foot)
	nr.text = str(player.nr)
	attributes_average.text = str(player.get_overall())
	prestige.text = str(player.prestige)
	value.text = FormatUtil.currency(player.value)
	
