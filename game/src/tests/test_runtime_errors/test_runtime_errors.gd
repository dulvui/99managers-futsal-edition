# SPDX-FileCopyrightText: 2025 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TestRuntimeErrors
extends Test


func test() -> void:
	print("test: runtime errors...")

	print("test: load all scenes...")
	var scene_paths: Array[String] = find_files("res://src/", ".tscn")
	# load scripts and check for possibe runtime errors while loading
	for path: String in scene_paths:
		var TestScene: PackedScene = load(path)
		assert(TestScene != null)
		var instance: Node = TestScene.instantiate()
		assert(instance != null)
	print("test: load all scene done.")

	print("test: load all scripts...")
	var script_paths: Array[String] = find_files("res://src/", ".gd")
	# load scripts and check for possibe runtime errors while loading
	for path: String in script_paths:
		var script: GDScript = load(path)
		assert(script != null)
		assert(script.can_instantiate())

		# lint checks
		# skip linting for this file
		if "test_runtime_errors.gd" in path:
			continue

		var lines: PackedStringArray = script.source_code.split("\n")
		for i: int in lines.size():
			var line: String = lines[i]

			# double empty line between func
			if line.begins_with("func"):
				assert(lines[i - 1].is_empty() or lines[i - 1].begins_with("#"))
				assert(lines[i - 2].is_empty() or lines[i - 2].begins_with("#"))
				assert(not lines[i - 3].is_empty() or not lines[i - 3].begins_with("#"))

			# =- instead of -=
			assert(not "=-" in line)
			# =+ instead of +=
			assert(not "=+" in line)
			# double space
			assert(not "  " in line)

		# TODO check in method list if _init has all default parameters
		# if yes, try to create instance
		# var instance: Object = script.new()
		# assert(instance != null)
	print("test: load all scripts done.")

	print("test: runtime errors done.")


func find_files(path: String, suffix: String) -> Array[String]:
	var scripts: Array[String] = []
	var dir: DirAccess = DirAccess.open(path)
	if dir == null:
		print("error while opening %s" % path)
		return scripts

	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while not file_name.is_empty():
		var full_path: String = path + file_name
		if dir.current_is_dir():
			scripts.append_array(find_files(full_path + "/", suffix))
		elif file_name.ends_with(suffix):
			scripts.append(full_path)
		file_name = dir.get_next()

	return scripts

