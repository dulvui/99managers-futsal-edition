# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends Control

@onready var nations: OptionButton = %Nationality
@onready var manager_name: LineEdit = %Name
@onready var manager_surname: LineEdit = %SurName
@onready var continue_button: Button = %Continue


func _ready() -> void:
	InputUtil.start_focus(self)

	# reset temp values
	if Global.manager:
		manager_name.text = Global.manager.name
		manager_surname.text = Global.manager.surname

	for nation: Nation in Global.world.get_all_nations():
		nations.add_item(nation.name)
	
	continue_button.disabled = manager_name.text.length() * manager_surname.text.length() == 0


func _on_back_pressed() -> void:
	Main.previous_scene()


func _on_continue_pressed() -> void:
	if manager_name.text.length() * manager_surname.text.length() > 0:
		var manager: Manager = Manager.new()
		manager.name = manager_name.text
		manager.surname = manager_surname.text
		manager.nation = Global.world.get_all_nations()[nations.selected].name
		Global.manager = manager

		Main.change_scene(Const.SCREEN_SETUP_TEAM)


func _on_sur_name_text_changed(_new_text: String) -> void:
	continue_button.disabled = manager_name.text.length() * manager_surname.text.length() == 0


func _on_name_text_changed(_new_text: String) -> void:
	continue_button.disabled = manager_name.text.length() * manager_surname.text.length() == 0

