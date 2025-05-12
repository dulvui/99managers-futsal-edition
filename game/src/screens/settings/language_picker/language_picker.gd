# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends HFlowContainer

signal language_change

# ordered alphabetically
const LANGUAGES: Dictionary = {
	"en": "English",
	"pt": "Portuguese",
	"pt_BR": "Portuguese (BR)",
	"es": "Español",
	"it": "Italiano",
	"fr": "Français",
	"de": "Deutsch",
	"tr_TR": "Türkçe",
	"apc": "اللهجة الشامية",
	"id": "Bahasa Indonesia",
	"uk": "Українська",
}


func _ready() -> void:
	var button_group: ButtonGroup = ButtonGroup.new()
	for language_key: String in LANGUAGES.keys():
		var button: Button = DefaultButton.new()
		button.text = LANGUAGES[language_key]
		button.button_group = button_group
		# toggle active language
		button.button_pressed = Global.config.language == language_key
		button.pressed.connect(_on_button_pressed.bind(language_key))
		add_child(button)


func _on_button_pressed(language_key: String) -> void:
	Global.config.set_lang(language_key)
	Main.check_layout_direction()
	language_change.emit()

