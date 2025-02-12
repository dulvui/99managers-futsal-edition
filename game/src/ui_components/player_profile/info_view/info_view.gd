# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name InfoView
extends GridContainer

var team_id: int

@onready var player_name: Label = %Name
@onready var pos: Label = %Position
@onready var alt_pos: Label = %AltPosition
@onready var age: Label = %Age
@onready var foot: Label = %Foot
@onready var nationality: Label = %Nationality
@onready var team_link: LinkButton = %TeamLink
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
	foot.text = Enum.get_foot_text(player)
	nationality.text = tr(player.nation)
	team_link.text = player.team
	prestige.text = str(player.prestige)
	value.text = FormatUtil.currency(player.value)

	team_id = player.team_id


func _on_team_link_pressed() -> void:
	LinkUtil.link_team_id(team_id)


