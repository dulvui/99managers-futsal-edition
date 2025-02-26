# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name VisualMatchStats
extends GridContainer


@onready var goals_home: Label = %GoalsHome
@onready var goals_away: Label = %GoalsAway
@onready var possession_home: Label = %PossessionHome
@onready var possession_away: Label = %PossessionAway
@onready var shots_home: Label = %ShotsHome
@onready var shots_away: Label = %ShotsAway
@onready var shots_hit_post_home: Label = %ShotsHitPostHome
@onready var shots_hit_post_away: Label = %ShotsHitPostAway
@onready var passes_home: Label = %PassesHome
@onready var passes_away: Label = %PassesAway
@onready var kick_ins_home: Label = %KickInsHome
@onready var kick_ins_away: Label = %KickInsAway
@onready var free_kicks_home: Label = %FreeKicksHome
@onready var free_kicks_away: Label = %FreeKicksAway
@onready var penalties_home: Label = %PenaltiesHome
@onready var penalties_away: Label = %PenaltiesAway
@onready var penalties_10m_home: Label = %Penalties10mHome
@onready var penalties_10m_away: Label = %Penalties10mAway
@onready var fouls_home: Label = %FoulsHome
@onready var fouls_away: Label = %FoulsAway
@onready var tackles_home: Label = %TacklesHome
@onready var tackles_away: Label = %TacklesAway
@onready var corners_home: Label = %CornersHome
@onready var corners_away: Label = %CornersAway
@onready var yellow_cards_home: Label = %YellowCardsHome
@onready var yellow_cards_away: Label = %YellowCardsAway
@onready var red_cards_home: Label = %RedCardsHome
@onready var red_cards_away: Label = %RedCardsAway


func update_stats(home: MatchStatistics, away: MatchStatistics) -> void:
	goals_home.text = str(home.goals)
	goals_away.text = str(away.goals)
	possession_home.text = str(home.possession) + " %"
	possession_away.text = str(away.possession) + " %"
	shots_home.text = "%d (%d)" % [home.shots, home.shots_on_target]
	shots_away.text = "%d (%d)" % [away.shots, away.shots_on_target]
	shots_hit_post_home.text = str(home.shots_hit_post)
	shots_hit_post_away.text = str(away.shots_hit_post)
	passes_home.text = "%d (%d)" % [home.passes, home.passes_success]
	passes_away.text = "%d (%d)" % [away.passes, away.passes_success]
	kick_ins_home.text = str(home.kick_ins)
	kick_ins_away.text = str(away.kick_ins)
	free_kicks_home.text = str(home.free_kicks)
	free_kicks_away.text = str(away.free_kicks)
	penalties_home.text = str(home.penalties)
	penalties_away.text = str(away.penalties)
	penalties_10m_home.text = str(home.penalties_10m)
	penalties_10m_away.text = str(away.penalties_10m)
	fouls_home.text = str(home.fouls)
	fouls_away.text = str(away.fouls)
	tackles_home.text = "%d (%d)" % [home.tackles, home.tackles_success]
	tackles_away.text = "%d (%d)" % [away.tackles, away.tackles_success]
	corners_home.text = str(home.corners)
	corners_away.text = str(away.corners)
	yellow_cards_home.text = str(home.yellow_cards)
	yellow_cards_away.text = str(away.yellow_cards)
	red_cards_home.text = str(home.red_cards)
	red_cards_away.text = str(away.red_cards)

