# SPDX-FileCopyrightText: 2025 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name FileUtil

var err: Error


func _init() -> void:
	err = OK


func read(path: String) -> FileAccess:
	var file: FileAccess
	file = FileAccess.open(path, FileAccess.READ)
	_check_errors(file)
	return file


func write(path: String, append: bool = false) -> FileAccess:
	# set needed flags
	var flags: FileAccess.ModeFlags = FileAccess.WRITE
	if append:
		flags = FileAccess.READ_WRITE

	# create directory, if not existing yet
	if flags != FileAccess.ModeFlags.READ:
		var dir_path: String = path.get_base_dir()
		var dir: DirAccess = DirAccess.open(DataUtil.USER_PATH)
		if not dir.dir_exists(dir_path):
			print("dir %s not found, creating now..." % dir_path)
			err = dir.make_dir_recursive(dir_path)
			if err != OK:
				push_warning("error while creating %s error with code %d" % [dir_path, err])
				return

	var file: FileAccess
	file = FileAccess.open(path, flags)
	_check_errors(file)
	return file


func _check_errors(file: FileAccess) -> void:
	if file == null:
		err = FileAccess.get_open_error()
		push_warning("error while opening file: error with code %d" % err)
		return

	# file is not null, but still might had errors
	err = file.get_error()
	if err != OK:
		push_warning("error while opening file: error with code %d" % err)

