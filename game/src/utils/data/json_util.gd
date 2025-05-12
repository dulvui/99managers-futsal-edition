# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name JSONUtil


var json: JSON
var file_util: FileUtil


func _init() -> void:
	file_util = FileUtil.new()
	json = JSON.new()


func save(path: String, resource: JSONResource) -> void:
	print("converting resurce...")
	var json_dict: Dictionary = resource.to_json()
	print("converting resource done.")

	var file: FileAccess = file_util.write(path)

	if file == null:
		push_error("error while opening json file %s" % path)
		return

	# save to file
	file.store_string(JSON.stringify(json_dict))
	file.close()

	# check again for file errors
	var err: Error = file.get_error()
	if err != OK:
		print("again opening file error with code %d" % err)
		print(err)
		return

	print("saving %s done..." % path)


func load(path: String, resource: JSONResource) -> Error:
	var file: FileAccess = file_util.read(path)

	if file == null:
		push_error("error while opening json file %s with error %d" % [path, file_util.err])
		return file_util.err

	# parse file to json
	var file_text: String = file.get_as_text()
	var err: Error = json.parse(file_text)

	# check for parsing errors
	if err != OK:
		print("parsing file %s error with code %d" % [path, err])
		return err

	file.close()

	# convert to json resource
	var parsed_json: Dictionary = json.data
	resource.from_json(parsed_json)

	return OK

