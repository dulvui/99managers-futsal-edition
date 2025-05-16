# SPDX-FileCopyrightText: 2025 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends VBoxContainer
class_name CustomTabContainer

var tab_names: Array[String]
var tab_count: int
var active_tab: int

var buttons: Array[DefaultButton]
var views: Array[Control]

@onready var buttons_container: HBoxContainer = %Buttons
@onready var buttons_bar: HBoxContainer = %ButtonsBar


# pot translation generation doesn't currently detect export variables, that could be used here
# https://github.com/godotengine/godot-proposals/issues/10139
func setup(p_tab_names: Array[String]) -> void:
	tab_names = p_tab_names

	active_tab = 0
	# remove button bar from counter
	tab_count = get_child_count() - 1

	# check that tab names array is same size as tab amount
	if tab_names.size() != tab_count:
		push_error("custom tab container has wrong amount of tab names")
		return

	# setup tab button bar
	var index: int = 0
	var button_group: ButtonGroup = ButtonGroup.new()
	for child: Control in get_children():
		if child == buttons_bar:
			continue

		# make sure tab names are ordered correctly and same name as child name
		var tab_name: String = tr(tab_names[index])
		var child_name: String = tr(child.name)
		if tab_name != child_name:
			push_error("tab name %s does not match child name %s" % [tab_name, child_name])
			return

		var button: DefaultButton = DefaultButton.new()
		button.text = tab_name
		button.pressed.connect(_on_button_pressed.bind(views.size()))
		button.button_group = button_group
		button.toggle_mode = true

		buttons_container.add_child(button)
		buttons.append(button)

		views.append(child)

		# show first entry and make button look pressed
		if index == 0:
			button.button_pressed = true
			child.show()
		else:
			child.hide()

		index += 1


func update_translations(p_tab_names: Array[String]) -> void:
	tab_names = p_tab_names

	var index: int = 0
	for button: DefaultButton in buttons:
		button.text = tr(tab_names[index])
		index += 1


func _on_button_pressed(index: int = active_tab) -> void:
	active_tab = index
	_show_active()


func _on_next_pressed() -> void:
	active_tab += 1
	_check_bounds()
	_show_active()


func _on_prev_pressed() -> void:
	active_tab -= 1
	_check_bounds()
	_show_active()


func _check_bounds() -> void:
	if active_tab >= tab_count:
		active_tab = 0
	elif active_tab < 0:
		active_tab = tab_count - 1


func _show_active() -> void:
	if views.is_empty():
		return

	for view: Control in views:
		view.hide()

	views[active_tab].show()
	buttons[active_tab].button_pressed = true

