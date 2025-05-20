# SPDX-FileCopyrightText: 2025 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name VisualStadium
extends Control

signal color_change(colors: StadiumColors)

var colors: StadiumColorsList

@onready var name_label: Label = %Name
@onready var capacity_label: Label = %Capacity
@onready var year_built_label: Label = %YearBuilt
@onready var year_renewed_label: Label = %YearRenewed
@onready var ticket_price_label: Label = %TicketPrice
@onready var maintenance_cost_label: Label = %MaintenanceCost

@onready var field: VisualField = %VisualField
@onready var goals: VisualGoals = %VisualGoals
@onready var camera: Camera2D = %Camera2D
@onready var color_buttons: HFlowContainer = %Colors


func _ready() -> void:
	colors = StadiumColorsList.new()

	var active_color: StadiumColors = colors.list[0]
	if Global.team:
		active_color = colors.select(Global.team.stadium.colors_index)

	field.setup(SimField.new(), active_color)
	goals.setup(SimField.new(), active_color)
	camera.zoom = Vector2(0.9 / Global.config.theme_scale, 0.9 / Global.config.theme_scale)

	# setup color buttons
	var button_group: ButtonGroup = ButtonGroup.new()
	var index: int = 0
	for color: StadiumColors in colors.list:
		print(color.name)
		var button: DefaultButton = DefaultButton.new()
		button.button_group = button_group
		button.toggle_mode = true
		button.text = tr(color.name)
		# pressed currently active button
		button.button_pressed = active_color == color
		button.pressed.connect(_on_color_button_pressed.bind(index))
		color_buttons.add_child(button)
		index += 1


func setup(stadium: Stadium) -> void:
	name_label.text = stadium.name
	capacity_label.text = "%s %d" % [tr("Capacity"), stadium.capacity]
	year_built_label.text = "%s %d" % [tr("Year built"), stadium.year_built]
	year_renewed_label.text = "%s %d" % [tr("Year renewed"), stadium.year_renewed]
	ticket_price_label.text = "%s %s" % [
		tr("Ticket price"), FormatUtil.currency(stadium.ticket_price)
	]
	maintenance_cost_label.text = "%s %s" % [
		tr("Maintenance cost"), FormatUtil.currency(stadium.maintenance_cost)
	]


func _on_color_button_pressed(index: int) -> void:
	var selected: StadiumColors = colors.list[index]
	field.set_colors(selected)
	goals.set_colors(selected)

	if Global.team:
		Global.team.stadium.colors_index = index

	color_change.emit(selected)

