# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TestCalendar
extends Test


func test() -> void:
	print("test: calendar...")
	Global.reset_data()
	test_months_and_days_size()
	print("test: calendar done.")


func test_months_and_days_size() -> void:
	print("test: test_months_and_days_size...")
	Global.start_date = Time.get_date_dict_from_system()
	var calendar: Calendar = Calendar.new()
	calendar.initialize()
	# 24 months, since always 2 years are present
	assert(calendar.months.size() == 24)
	assert(calendar.months[0].days.size() == 31)
	# TODO specialcase for february
	#assert(calendar.months[1].days.size() == 31)
	assert(calendar.months[2].days.size() == 31)
	assert(calendar.months[3].days.size() == 30)
	assert(calendar.months[4].days.size() == 31)
	assert(calendar.months[5].days.size() == 30)
	assert(calendar.months[6].days.size() == 31)
	assert(calendar.months[7].days.size() == 31)
	assert(calendar.months[8].days.size() == 30)
	assert(calendar.months[9].days.size() == 31)
	assert(calendar.months[10].days.size() == 30)
	assert(calendar.months[11].days.size() == 31)
	# next season
	calendar.initialize(true)
	# always 24 months
	assert(calendar.months.size() == 24)

	print("test: test_months_and_days_size done...")
