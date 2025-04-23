# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TestGameloop
extends Test


func test() -> void:
	print("test: game loop...")
	test_full_season()
	print("test: game loop done.")


func test_full_season() -> void:
	print("test: test full season...")

	Tests.setup_mock_world(true)

	# set team to null, so that ALL matches get simulated
	# world.random_results checks for active team
	Global.team = null

	for season: int in range(50):
		print("test: season %d..." % [season])
		while not Global.calendar.is_season_finished():
			Global.calendar.next_day()
			Global.world.random_results()

		Global.next_season(false)
		print("test: season %d done..." % [season])

	print("test: test full season done.")
