# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends Node

var thread: Thread


func _ready() -> void:
	thread = Thread.new()


func save_all_data() -> void:
	if thread and thread.is_started():
		print("thread is already running")
		return
	thread.start(_save_all_data, Thread.Priority.PRIORITY_HIGH)


func load_data() -> void:
	if thread and thread.is_started():
		print("thread is already running")
		return
	thread.start(_load_data)


func generate_world() -> void:
	if thread and thread.is_started():
		print("thread is already running")
		return
	thread.start(_generate_world, Thread.Priority.PRIORITY_HIGH)


func random_results() -> void:
	if thread and thread.is_started():
		print("thread is already running")
		return
	thread.start(_random_results, Thread.Priority.PRIORITY_HIGH)


func _save_all_data() -> void:
	print("save data in thread...")
	Global.save_all_data()
	call_deferred("_loading_done")


func _load_data() -> void:
	print("load data in thread...")
	ResUtil.load_save_state_data()
	call_deferred("_loading_done")


func _generate_world() -> void:
	print("generating world in thread...")
	# create world, teams and players
	var generator: Generator = Generator.new()
	var world: World = generator.generate_world()
	generator.generate_players(world)

	# create matches
	var match_util: MatchUtil = MatchUtil.new(world)
	match_util.initialize_matches()

	# assign world
	Global.world = world
	call_deferred("_loading_done")


func _random_results() -> void:
	print("calculating random result in thread...")
	Global.world.random_results()
	call_deferred("_loading_done")


func _loading_done() -> void:
	LoadingUtil.done()
	thread.wait_to_finish()
	print("thread done.")


func _exit_tree() -> void:
	if thread and thread.is_started():
		thread.wait_to_finish()
