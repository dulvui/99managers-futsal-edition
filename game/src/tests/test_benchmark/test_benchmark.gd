# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TestBenchmark
extends Test


var match_engine: MatchEngine
var generator: Generator


func test() -> void:
	print("test: benchmark...")
	generator = Generator.new()
	match_engine = MatchEngine.new()
	Global.world = generator.generate_world()

	MatchCombinationUtil.initialize_matches()

	# set active team and league, so next match day can be found
	for continent: Continent in Global.world.continents:
		if continent.is_competitive():
			for nation: Nation in continent.nations:
				if nation.is_competitive():
					Global.world.active_team_id = nation.leagues[0].teams[0].id
					Global.team = nation.leagues[0].teams[0]
					Global.league = nation.leagues[0]

	Tests.find_next_matchday()

	print("test: calculate random results...")
	Global.world.random_results()
	print("test: benchmark done.")
