# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends Node

signal loading_done

var thread: Thread
var mutex: Mutex
var locale: String


func _ready() -> void:
	thread = Thread.new()
	mutex = Mutex.new()


func save_all_data() -> void:
	if thread and thread.is_started():
		print("thread is already running")
		return
	# set save state language always to english
	locale = TranslationServer.get_locale()
	TranslationServer.set_locale("en")

	thread.start(_save_all_data, Thread.Priority.PRIORITY_HIGH)


func load_data() -> void:
	if thread and thread.is_started():
		print("thread is already running")
		return
	thread.start(_load_data)


func generate_world(
	generation_seed: String,
	player_names: Enum.PlayerNames,
	world_file_path: String = Const.WORLD_CSV_PATH
) -> void:
	if thread and thread.is_started():
		print("thread is already running")
		return
	thread.start(
		_generate_world.bind(generation_seed, player_names, world_file_path),
		Thread.Priority.PRIORITY_HIGH
	)


func random_results() -> void:
	if thread and thread.is_started():
		print("thread is already running")
		return
	thread.start(_random_results, Thread.Priority.PRIORITY_HIGH)


func _save_all_data() -> void:
	print("save data in thread...")
	mutex.lock()

	DataUtil.save_config()
	DataUtil.save_save_states()
	DataUtil.save_data()

	mutex.unlock()
	call_deferred("_saving_done")


func _load_data() -> void:
	print("load data in thread...")
	mutex.lock()

	DataUtil.load_data()

	mutex.unlock()
	call_deferred("_loading_done")


func _generate_world(
	generation_seed: String,
	player_names: Enum.PlayerNames,
	world_file_path: String = Const.WORLD_CSV_PATH
) -> void:
	print("generating world in thread...")
	mutex.lock()

	var generator: Generator = Generator.new(generation_seed, player_names)

	var generator_world: GeneratorWorld = GeneratorWorld.new()
	var world: World = generator_world.init_world()
	var success: bool = generator.initialize_world(world, world_file_path)

	if not success:
		mutex.unlock()
		call_deferred("_loading_done")
		return

	mutex.unlock()
	# NEEDED TO HAVE CORRECT WORLD ASSIGNED
	# OTHERWISE NOT ALL CHANGES MADE IN THREAD ARE SAVED
	Global.world = world

	call_deferred("_loading_done")


func _random_results() -> void:
	print("calculating random result in thread...")
	mutex.lock()

	Global.match_list.random_results()

	mutex.unlock()
	call_deferred("_loading_done")



func _loading_done() -> void:
	if thread.is_started():
		await thread.wait_to_finish()
	loading_done.emit()


func _saving_done() -> void:
	if thread.is_started():
		thread.wait_to_finish()
	loading_done.emit()

	# reset locale
	TranslationServer.set_locale(locale)
	print("thread done.")


func _exit_tree() -> void:
	if thread:
		thread.wait_to_finish()

