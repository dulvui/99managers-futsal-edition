# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TestMatchEngine
extends Test


func test() -> void:
	print("test: match engine...")
	test_deterministic_simulations()
	test_benchmark()
	print("test: match engine done.")


func test_deterministic_simulations() -> void:
	print("test: deterministic simulation...")
	var matches: Array[Match] = []

	const MATCH_AMOUNT: int = 2
	const SEED_AMOUNT: int = 9

	var match_engine: MatchEngine = MatchEngine.new()

	# simulate matches
	for i: int in SEED_AMOUNT:
		matches = []
		for j: int in MATCH_AMOUNT:
			var matchz: Match = Match.new()

			var home_team: Team = Tests.create_mock_team()
			var away_team: Team = Tests.create_mock_team()

			# use always same match id/seed
			matchz.id = i
			matches.append(matchz)
			matchz.setup(home_team, away_team, 1, "test")
			match_engine.setup(matchz, home_team, away_team)
			match_engine.simulate()

			matchz.set_result(
				match_engine.home_team.stats.goals,
				match_engine.away_team.stats.goals,
				match_engine.home_team.stats.penalty_shootout_goals,
				match_engine.away_team.stats.penalty_shootout_goals,
			)
			print("test: match %d with seed %d calculated" % [j + 1, i])

		# check results
		for j: int in MATCH_AMOUNT:
			print("check %d - %d" % [matches[j].home_goals, matches[j - 1].home_goals])

			assert(matches[j].home_goals == matches[j - 1].home_goals)
			assert(matches[j].away_goals == matches[j - 1].away_goals)

	print("test: deterministic simulation done.")


func test_benchmark() -> void:
	print("test: match engine benchmark...")
	var matchz: Match = Match.new()
	var home_team: Team = Tests.create_mock_team()
	var away_team: Team = Tests.create_mock_team()
	matchz.setup(home_team, away_team, 1, "test")

	var match_engine: MatchEngine = MatchEngine.new()
	match_engine.setup(matchz, home_team, away_team)
	match_engine.simulate()
	print("test: match engine benchmark done.")

