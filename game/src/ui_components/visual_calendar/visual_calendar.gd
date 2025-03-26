# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name VisualCalendar
extends HBoxContainer

const VisualDayScene: PackedScene = preload(
	"res://src/ui_components/visual_calendar/visual_day/visual_day.tscn"
)

var current_month: int
var current_year: int
var max_months: int

@onready var match_list: VisualMatchList = %MatchList
@onready var days: GridContainer = %Days
@onready var page_label: Label = %Page


func _ready() -> void:
	max_months = Global.world.calendar.months.size()
	current_month = Global.world.calendar.date.month
	current_year = Global.world.calendar.date.year
	setup()


func setup() -> void:
	setup_days()
	match_list.setup(Global.world.calendar.day())


func setup_days() -> void:
	# clean grid container
	for child: Node in days.get_children():
		if not child is Label:
			child.queue_free()

	# to start with monday, fill other days with placeholders
	var monday_counter: int = 7
	while (
		Global.world.calendar.month(current_month).days[monday_counter].weekday
		!= Enum.Weekdays.MONDAY
	):
		monday_counter -= 1

		var placeholder: Control = Control.new()
		placeholder.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		placeholder.size_flags_vertical = Control.SIZE_EXPAND_FILL
		days.add_child(placeholder)

	# add days
	for day: Day in Global.world.calendar.month(current_month).days:
		var calendar_day: VisualDay = VisualDayScene.instantiate()
		days.add_child(calendar_day)
		# add matches
		var matchz: Match = Global.world.match_list.get_active_match(day)
		calendar_day.setup(day, matchz)
		calendar_day.show_match_list.connect(_on_calendar_day_pressed.bind(day, matchz))

		# make current day active
		if day == Global.world.calendar.day():
			calendar_day.select()

	var active_year: String = str(current_year + (int(current_month - 1) / 12))
	var active_month: String = Enum.get_month_text((current_month - 1) % 12)
	page_label.text = active_month + " " + active_year


func _on_calendar_day_pressed(day: Day, matchz: Match = null) -> void:
	if matchz == null:
		match_list.setup(day)
	else:
		var competition: Competition = Global.world.get_competition_by_id(matchz.competition_id)
		match_list.setup(day, competition)


func _on_prev_pressed() -> void:
	current_month -= 1
	if current_month < 1:
		current_month = 1
	setup()


func _on_next_pressed() -> void:
	current_month += 1
	if current_month > max_months:
		current_month = max_months
	setup()


func _on_today_pressed() -> void:
	current_month = Global.world.calendar.date.month
	setup()
