# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name GeneratorValidator


func validate_world(world: World) -> bool:
	var league_names: Array[String] = []
	var team_names: Array[String] = []

	# check league size
	for continent: Continent in world.continents:
		for nation: Nation in continent.nations:
			for league: League in nation.leagues:
				# check duplicate league names
				if league_names.find(league.name) >= 0:
					push_error("duplicate league name found %s " % league.name)
				else:
					league_names.append(league.name)

				# max amount check
				if league.teams.size() > Const.LEAGUE_MAX_TEAMS:
					push_warning("too many teams in league " + league.name)
					Global.generation_warnings.append(Enum.GenerationWarning.WARN_LEAGUE_SIZE_MAX)
					league.teams = league.teams.slice(0, Const.LEAGUE_MAX_TEAMS)

				# even amount check
				if league.teams.size() % 2 == 1:
					push_warning("odd team amounts in league " + league.name)
					Global.generation_warnings.append(Enum.GenerationWarning.WARN_LEAGUE_SIZE_ODD)
					# remove last team
					league.teams = league.teams.slice(0, league.teams.size())

				# min amount check
				if league.teams.size() < Const.LEAGUE_MIN_TEAMS:
					push_warning("too few teams in league " + league.name)
					Global.generation_errors.append(Enum.GenerationError.ERR_LEAGUE_SIZE_MIN)
					return false

				# check duplicate team names
				for team: Team in league.teams:
					# check duplicate league names
					if team_names.find(team.name) >= 0:
						push_error("duplicate team name found %s " % team.name)
					else:
						team_names.append(team.name)

	# check if at least one continent is competitive, after league check
	var competitive_continent_found: bool = false
	for continent: Continent in world.continents:
		if continent.is_competitive():
			competitive_continent_found = true
			break
	if not competitive_continent_found:
		push_error("world has no competitive continent")
		Global.generation_errors.append(Enum.GenerationError.ERR_LEAGUE_NO_VALID)
		return false

	return true

