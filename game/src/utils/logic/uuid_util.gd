# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name UUID
extends Object


# generate random seed like 26374-28372-887463
static func new_uuid() -> String:
	return (
		str(randi_range(100000, 999999))
		+ "-"
		+ str(randi_range(100000, 999999))
		+ "-"
		+ str(randi_range(100000, 999999))
	)

