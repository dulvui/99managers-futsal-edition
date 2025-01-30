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
	return buffer[buffer_index]


