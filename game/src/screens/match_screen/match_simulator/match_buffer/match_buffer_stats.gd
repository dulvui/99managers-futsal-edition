# SPDX-FileCopyrightText: 2025 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name MatchBufferStats
extends MatchBuffer


func save(engine: MatchEngine) -> void:
	var entry: MatchBufferEntryBall = MatchBufferEntryBall.new()
	entry.ticks = engine.ticks
	entry.pos = engine.field.ball.pos
	append(entry)


func get_entry() -> MatchBufferEntryBall:
	return super() as MatchBufferEntryBall


