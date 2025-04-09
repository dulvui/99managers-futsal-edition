# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends Node

signal loading_done

var thread: Thread
var locale: String

func _ready() -> void:
	thread = Thread.new()


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


func generate_world(world: World, world_file_path: String = "") -> void:
	if thread and thread.is_started():
		print("thread is already running")
		return
	thread.start(_generate_world.bind(world, world_file_path), Thread.Priority.PRIORITY_HIGH)


func random_results() -> void:
	if thread and thread.is_started():
		print("thread is already running")
		return
	thread.start(_random_results, Thread.Priority.PRIORITY_HIGH)


func _save_all_data() -> void:
	print("save data in thread...")
	Global.save_all_data()
	call_deferred("_saving_done")


func _load_data() -> void:
	print("load data in thread...")
	DataUtil.load_save_state_data()
	call_deferred("_loading_done")


func _generate_world(world: World, world_file_path: String = "") -> void:
	print("generating world in thread...")

	# initialize world with laegues and teams
	# but only with team name and id
	# because histroy generation swaps team ids and names
	var generator: Generator = Generator.new()
	var success: bool = generator.generate_teams(world, world_file_path)
	# go back if world is not valid
	if not success:
		print("error while reading world file %d errors occurred." % Global.generation_errors.size())
		call_deferred("_loading_done")
		return

	# assign world
	Global.world = world

	# history
	var history: GeneratorHistory = GeneratorHistory.new()
	# first generate clubs history with promotions, delegations, cup wins
	history.generate_club_history()

	# initialize players and other custom team properties after club history
	# because histroy generation swaps team ids and names
	var success_players: bool = generator.generate_players(world, world_file_path)
	# go back if players are not valid
	if not success_players:
		print("error while reading players from world file %d errors occurred." % Global.generation_errors.size())
		call_deferred("_loading_done")
		return

	# then generate player histroy with transfers and statistics
	history.generate_player_history()

	# create matches
	var match_util: MatchUtil = MatchUtil.new(world)
	match_util.initialize_matches()
	call_deferred("_loading_done")


func _random_results() -> void:
	print("calculating random result in thread...")
	Global.world.random_results()
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
	if thread and thread.is_started():
		thread.wait_to_finish()

