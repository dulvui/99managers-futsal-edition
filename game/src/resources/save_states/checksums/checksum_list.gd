# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name ChecksumList
extends JSONResource

@export var list: Array[Checksum]


func _init(
	p_list: Array[Checksum] = [],
) -> void:
	list = p_list


func save(path: StringName) -> void:
	for checksum: Checksum in list:
		if checksum.path == path:
			checksum.unix_timestamp = int(Time.get_unix_time_from_system())
			checksum.sha256 = FileAccess.get_sha256(path)
			return

	var checksum: Checksum = Checksum.new()
	checksum.path = path
	checksum.unix_timestamp = int(Time.get_unix_time_from_system())
	checksum.sha256 = FileAccess.get_sha256(path)
	list.append(checksum)


func check(path: StringName) -> bool:
	for checksum: Checksum in list:
		if checksum.path == path:
			return FileAccess.get_sha256(path) == checksum.sha256

	push_warning("checksum check failed, path %s not found in list" % path)
	return false

