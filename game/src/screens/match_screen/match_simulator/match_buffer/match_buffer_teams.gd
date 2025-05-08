# SPDX-FileCopyrightText: 2025 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name MatchBufferTeams
extends MatchBuffer


func save(engine: MatchEngine) -> void:
	var entry: MatchBufferEntryTeams = MatchBufferEntryTeams.new()
	entry.ticks = engine.ticks

	for player: SimPlayer in engine.home_team.players:
		entry.home_pos.append(player.pos)
		entry.home_info.append(str(player.res.nr) + " " + player.res.surname)
		entry.home_head_look.append(player.head_look)
		entry.home_skintone.append(player.res.skintone)
		entry.home_haircolor.append(player.res.haircolor)
		entry.home_eyecolor.append(player.res.eyecolor)

	for player: SimPlayer in engine.away_team.players:
		entry.away_pos.append(player.pos)
		entry.away_info.append(str(player.res.nr) + " " + player.res.surname)
		entry.away_head_look.append(player.head_look)
		entry.away_skintone.append(player.res.skintone)
		entry.away_haircolor.append(player.res.haircolor)
		entry.away_eyecolor.append(player.res.eyecolor)

	append(entry)


func get_entry() -> MatchBufferEntryTeams:
	return super() as MatchBufferEntryTeams

