# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name VisualMatchStats
extends GridContainer


var home_labels: Dictionary
var away_labels: Dictionary


func _ready() -> void:
	home_labels = {}
	away_labels = {}

	# create labels
	var match_stats: MatchStatistics = MatchStatistics.new()
	for property: Dictionary in match_stats.get_property_list():
		if property.usage == Const.CUSTOM_PROPERTY:
			var label: Label = Label.new()
			ThemeUtil.bold(label)
			label.custom_minimum_size.x = 400
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			var statistic: String = property.name
			label.text = statistic.to_upper()

			var home_label: Label = Label.new()
			home_label.text = "0" # NO_TRANSLATE 
			home_labels[statistic] = home_label
			
			var away_label: Label = Label.new()
			away_label.text = "0" # NO_TRANSLATE
			away_labels[statistic] = away_label

			add_child(home_label)
			add_child(label)
			add_child(away_label)


func update_stats(home_stats: MatchStatistics, away_stats: MatchStatistics) -> void:
	# home
	for property: Dictionary in home_stats.get_property_list():
		if property.usage == Const.CUSTOM_PROPERTY:
			var statistic: String = property.name
			var value: String = str(home_stats[property.name])
			if "possess" in statistic:
				value += " %"
			home_labels[statistic].text = value
	# away
	for property: Dictionary in away_stats.get_property_list():
		if property.usage == Const.CUSTOM_PROPERTY:
			var statistic: String = property.name
			var value: String = str(away_stats[property.name])
			if "possess" in statistic:
				value += " %"
			away_labels[statistic].text = value
