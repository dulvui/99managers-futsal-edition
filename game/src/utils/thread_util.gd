# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends Node

var thread: Thread

func _ready() -> void:
	thread = Thread.new()


func initialize_game() -> void:
	if thread and thread.is_started():
		print("thread is already running")
		return
	thread.start(_initialize_game, Thread.Priority.PRIORITY_HIGH)


func save_all_data() -> void:
	if thread and thread.is_started():
		print("thread is already running")
		return
	thread.start(_save_all_data, Thread.Priority.PRIORITY_HIGH)


func load_data() -> void:
	if thread and thread.is_started():
		print("thread is already running")
		return
	thread.start(_save_all_data, Thread.Priority.PRIORITY_HIGH)


func generate_players() -> void:
	if thread and thread.is_started():
		print("thread is already running")
		return
	thread.start(_generate_players, Thread.Priority.PRIORITY_HIGH)


func random_results() -> void:
	if thread and thread.is_started():
		print("thread is already running")
		return
	thread.start(_random_results, Thread.Priority.PRIORITY_HIGH)


func _initialize_game() -> void:
	print("initializing game in thread...")
	Global.initialize_game()
	# Global.save_all_data()
	call_deferred("_loading_done")


func _save_all_data() -> void:
	print("save data in thread...")
	Global.save_all_data()
	call_deferred("_loading_done")


func _load_data() -> void:
	print("load data in thread...")
	ResUtil.load_save_state_data()
	call_deferred("_loading_done")


func _generate_players() -> void:
	print("generating world in thread...")
	var generator: Generator = Generator.new()
	generator.generate_players()
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
