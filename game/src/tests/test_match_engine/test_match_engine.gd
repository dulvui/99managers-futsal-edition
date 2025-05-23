# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TestMatchEngine
extends Test


func test() -> void:
	print("test: match engine...")

	Global.reset_data()
	test_deterministic_simulations()

	Global.reset_data()
	test_benchmark()

	print("test: match engine done.")


func test_deterministic_simulations() -> void:
	print("test: deterministic simulation...")
	var matches: Array[Match] = []

	const MATCH_AMOUNT: int = 2
	const SEED_AMOUNT: int = 9

	# simulate matches
	for i: int in SEED_AMOUNT:
		matches = []
		for j: int in MATCH_AMOUNT:
			var match_engine: MatchEngine = MatchEngine.new()
			var matchz: Match = Match.new()

			var home_team: Team = Tests.create_mock_team()
			var away_team: Team = Tests.create_mock_team()

			matches.append(matchz)
			matchz.setup(home_team.to_basic(), away_team.to_basic(), 1, "test")
			# use always same match id/seed
			matchz.id = i
			match_engine.setup(matchz, home_team, away_team)

			print("test: simulating match...")
			var start_time: int = Time.get_ticks_msec()

			match_engine.simulate()

			# print milliseconds passed for simulation
			var load_time: int = Time.get_ticks_msec() - start_time
			print("test: simulated in: " + str(load_time) + " ms")
			print("test: result: %d - %d" % [matchz.home_goals, matchz.away_goals])

			print("test: match %d with seed %d calculated" % [j + 1, i])

		# check results
		for j: int in MATCH_AMOUNT:
			# print("check %d - %d" % [matches[j].home_goals, matches[j - 1].away_goals])
			assert(matches[j].home_goals == matches[j - 1].home_goals)
			assert(matches[j].away_goals == matches[j - 1].away_goals)

	print("test: deterministic simulation done.")


func test_benchmark() -> void:
	print("test: match engine benchmark...")
	var matchz: Match = Match.new()
	var home_team: Team = Tests.create_mock_team()
	var away_team: Team = Tests.create_mock_team()
	matchz.setup(home_team.to_basic(), away_team.to_basic(), 1, "test")

	var match_engine: MatchEngine = MatchEngine.new()
	match_engine.setup(matchz, home_team, away_team)
	match_engine.simulate()
	print("test: match engine benchmark done.")

