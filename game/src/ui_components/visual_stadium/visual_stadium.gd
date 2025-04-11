# SPDX-FileCopyrightText: 2025 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name VisualStadium
extends Control


@onready var name_label: Label = %Name
@onready var capacity_label: Label = %Capacity
@onready var year_built_label: Label = %YearBuilt
@onready var year_renewed_label: Label = %YearRenewed
@onready var ticket_price_label: Label = %TicketPrice
@onready var maintenance_cost_label: Label = %MaintenanceCost


func setup(stadium: Stadium) -> void:
	name_label.text = stadium.name
	capacity_label.text = "%s %d" % [tr("Capacity"), stadium.capacity]
	year_built_label.text = "%s %d" % [tr("Year built"), stadium.year_built]
	year_renewed_label.text = "%s %d" % [tr("Year renewed"), stadium.year_renewed]
	ticket_price_label.text = "%s %s" % [tr("Ticket price"), FormatUtil.currency(stadium.ticket_price)]
	maintenance_cost_label.text = "%s %s" % [tr("Maintenance cost"), FormatUtil.currency(stadium.maintenance_cost)]

