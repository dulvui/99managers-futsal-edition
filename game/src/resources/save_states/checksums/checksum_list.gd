# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name ChecksumList
extends JSONResource

@export var list: Dictionary[String, Checksum]


func _init(
	p_list: Dictionary[String, Checksum] = {},
) -> void:
	list = p_list


func save(path: StringName) -> void:
	var checksum: Checksum = list.get(path)

	if checksum == null:
		checksum = Checksum.new()
		checksum.path = path
		list[path] = checksum

	checksum.unix_timestamp = int(Time.get_unix_time_from_system())
	checksum.sha256 = FileAccess.get_sha256(path)


func check(path: StringName) -> bool:
	var checksum: Checksum = list.get(path)

	if checksum == null:
		return false

	return FileAccess.get_sha256(checksum.path) == checksum.sha256

