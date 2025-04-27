# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name JSONUtil

signal loading_failed

const COMPRESSION_ON: bool = false
const COMPRESSION_MODE: FileAccess.CompressionMode = FileAccess.CompressionMode.COMPRESSION_GZIP
const FILE_SUFFIX_COMPRESS: StringName = ".save"


func save(path: String, resource: JSONResource) -> void:
	print("converting resurce...")
	var json: Dictionary = resource.to_json()
	print("converting resource done.")

	# make sure path is lower case
	path = path.to_lower()
	print("saving json %s..." % path)

	# create directory, if not exist yet
	var dir_path: String = path.get_base_dir()
	var dir: DirAccess = DirAccess.open(DataUtil.USER_PATH)
	if not dir.dir_exists(path):
		print("dir %s not found, creating now..." % dir_path)
		var err_dir: Error = dir.make_dir_recursive(dir_path)
		if err_dir != OK:
			push_error("error while creating directory %s; error with code %d" % [dir_path, err_dir])
			return

	# print("saving resource...")
	var file: FileAccess
	if COMPRESSION_ON:
		path += FILE_SUFFIX_COMPRESS
		file = FileAccess.open_compressed(path, FileAccess.WRITE, COMPRESSION_MODE)
	else:
		file = FileAccess.open(path, FileAccess.WRITE)

	if file == null:
		breakpoint
		push_error("error while opening file: file is null")
		return

	# check for file errors
	var err: int = file.get_error()
	if err != OK:
		push_error("error while opening file: error with code %d" % err)
		return

	# save to file
	file.store_string(JSON.stringify(json))
	file.close()

	# check again for file errors
	err = file.get_error()
	if err != OK:
		print("again opening file error with code %d" % err)
		print(err)
		return

	print("saving %s done..." % path)


func load(path: String, resource: JSONResource) -> void:
	# make sure path is lower case
	path = path.to_lower()

	# open file
	var file: FileAccess
	if COMPRESSION_ON:
		path += FILE_SUFFIX_COMPRESS
		file = FileAccess.open_compressed(path, FileAccess.READ, FileAccess.COMPRESSION_GZIP)
	else:
		file = FileAccess.open(path, FileAccess.READ)

	# check errors
	var err: int = FileAccess.get_open_error()
	if err != OK:
		print("opening file %s error with code %d after backup attempt." % [path, err])
		loading_failed.emit()
		return

	# load and parse file
	var file_text: String = file.get_as_text()
	var json: JSON = JSON.new()
	var result: int = json.parse(file_text)

	# check for parsing errors
	if result != OK:
		print("parsing file %s error with code %d after backup" % [path, result])
		loading_failed.emit()
		return

	# convert to json resource
	file.close()

	var parsed_json: Dictionary = json.data
	resource.from_json(parsed_json)

