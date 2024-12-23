# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TestGameloop
extends Node


func test() -> void:
	print("test: game loop...")
	test_full_season()

	# test x seasons
	for season: int in range(20):
		print("test: season %d..." % [season])
		test_full_season()
		print("test: season %d done..." % [season])

	print("test: game loop.")


func test_full_season() -> void:
	print("test: test full season...")

	Tests.setup_mock_world(true)

	while not Global.world.calendar.is_season_finished():
		Global.world.calendar.next_day()
		Global.world.random_results()

	Global.next_season()

	print("test: test full season done...")
