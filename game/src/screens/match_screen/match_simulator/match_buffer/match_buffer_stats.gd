# SPDX-FileCopyrightText: 2025 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name MatchBufferStats
extends MatchBuffer


func save(engine: MatchEngine) -> void:
	var entry: MatchBufferEntryStats = MatchBufferEntryStats.new()
	entry.ticks = engine.ticks
	entry.seconds = engine.seconds
	entry.home_stats = engine.home_team.stats.duplicate()
	entry.away_stats = engine.away_team.stats.duplicate()
	append(entry)


func get_entry() -> MatchBufferEntryStats:
	return super() as MatchBufferEntryStats

