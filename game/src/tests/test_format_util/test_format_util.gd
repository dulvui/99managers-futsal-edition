# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TestFormatUtil
extends Test


func test() -> void:
	print("test: format util...")

	# numbers
	assert("100 000" == FormatUtil.format_number(100000))
	assert("1 000 000" == FormatUtil.format_number(1000000))
	assert("219 123 000 727" == FormatUtil.format_number(219123000727))

	print("test: format util done.")
