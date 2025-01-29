# SPDX-FileCopyrightText: 2025 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name MatchBuffer

var buffer: Array[Entry]
var buffer_size: int
var buffer_index: int


func setup(p_buffer_size: int) -> void:
	buffer_size = p_buffer_size
	buffer = []
	buffer_index = 0


func append(entry: Entry) -> void:
	buffer.append(entry)
	if buffer.size() > buffer_size:
		buffer.remove_at(0)


# TODO can be optimized by only saving deltas
class Entry:
	var tick: int


class Ball extends Entry:
	var pos: Vector2
	var rot: float


class Teams extends Entry:
	var home_players_pos: Array[Vector2]
	var home_players_head_direction: Array[Vector2]
	var home_players_info: Array[String]

	var away_players_pos: Array[Vector2]
	var away_players_head_direction: Array[Vector2]
	var away_players_info: Array[String]


class Stats extends Entry:
	var home_stats: MatchStatistics
	var away_stats: MatchStatistics
