# SPDX-FileCopyrightText: 2025 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name MatchBuffer

var buffer: Array[MatchBufferEntry]
var buffer_size: int
var buffer_index: int


func setup(p_buffer_size: int) -> void:
	buffer_size = p_buffer_size
	buffer = []
	buffer_index = 0


func append(entry: MatchBufferEntry) -> void:
	buffer.append(entry)
	if buffer.size() > buffer_size:
		buffer.remove_at(0)


func get_entry() -> MatchBufferEntry:
	if Global.match_speed == Const.MatchSpeed.FULL_GAME:
		return buffer[-1]

	if buffer_index < buffer.size() - 1:
		buffer_index += 1

	return buffer[buffer_index]


func start_replay(ticks_to_show: int = -1) -> void:
	# find buffer entry with corresponding tick
	buffer_index = buffer.size() - 1
	while buffer_index > 0:
		if buffer[buffer_index].ticks <= ticks_to_show:
			return
		buffer_index -= 1

