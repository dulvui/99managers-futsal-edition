# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends Node

var thread: Thread


func initialize_game() -> void:
	if thread and thread.is_started():
		print("thread is already running")
		return
	thread = Thread.new()
	thread.start(_initialize_game, Thread.Priority.PRIORITY_HIGH)


func save_world() -> void:
	if thread and thread.is_started():
		print("thread is already running")
		return
	thread = Thread.new()
	thread.start(_save_world, Thread.Priority.PRIORITY_HIGH)


func generate_world() -> void:
	if thread and thread.is_started():
		print("thread is already running")
		return
	thread = Thread.new()
	thread.start(_generate_world, Thread.Priority.PRIORITY_HIGH)


func random_results() -> void:
	if thread and thread.is_started():
		print("thread is already running")
		return
	thread = Thread.new()
	thread.start(_random_results, Thread.Priority.PRIORITY_HIGH)


func _initialize_game() -> void:
	print("initializing game in thread...")
	Global.call_deferred("initialize_game")
	Global.save_all_data(false)
	call_deferred("_loading_done")


func _save_world() -> void:
	print("save world in thread...")
	ResUtil.save_resource("world", Global.world)
	call_deferred("_loading_done")


func _generate_world() -> void:
	print("generating world in thread...")
	var generator: Generator = Generator.new()
	Global.world = generator.generate_world()
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
