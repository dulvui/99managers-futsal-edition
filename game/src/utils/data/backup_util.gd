# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name BackupUtil

const BACKUP_SUFFIX: StringName = ".backup"


func create(path: StringName) -> bool:
	var backup_path: StringName = path + BACKUP_SUFFIX
	print("creating backup for %s..." % backup_path)

	var dir_access: DirAccess = DirAccess.open(path.get_base_dir())
	if dir_access:
		dir_access.copy(path, backup_path)
		print("creating backup for %s done." % path)
		return true

	print("creating backup for %s gone wrong." % path)
	return false


func restore(path: String) -> bool:
	# check first, if file exists
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("backup file %s does not exist" % path)
		return false

	print("restoring backup for %s..." % path)
	var backup_path: StringName = path + BACKUP_SUFFIX

	var dir: DirAccess = DirAccess.open(path.get_base_dir())
	if dir:
		dir.copy(backup_path, path)
		print("restoring backup for %s done." % path)
		return true

	push_error("restoring backup for %s gone wrong." % path)
	return false

