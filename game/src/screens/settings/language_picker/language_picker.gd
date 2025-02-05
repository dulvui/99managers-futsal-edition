# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends HBoxContainer

signal language_change

const LANGUAGES: Dictionary = {
	"en": "English",
	"pt": "Portuguese",
	"pt_BR": "Portuguese (BR)",
	"it": "Italiano",
	"es": "Español",
	"de": "Deutsch",
	"ua": "Українська",
	"apc": "اللهجة الشامية",
}

func _ready() -> void:
	# toggle active language
	var button_group: ButtonGroup = ButtonGroup.new()
	for language_key: String in LANGUAGES.keys():
		var button: Button = DefaultButton.new()
		button.text = LANGUAGES[language_key]
		button.button_group = button_group
		button.button_pressed = Global.language == language_key 
		button.pressed.connect(_on_button_pressed.bind(language_key))
		add_child(button)

	print("language set:" + Global.language)


func _on_button_pressed(language_key: String) -> void:
	Global.set_lang(language_key)
	Main.check_layout_direction()
	language_change.emit()

