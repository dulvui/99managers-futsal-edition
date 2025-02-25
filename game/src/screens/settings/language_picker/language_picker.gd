# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends HFlowContainer

signal language_change

const LANGUAGES: Dictionary = {
	"en": "English",
	"pt": "Portuguese",
	"pt_BR": "Portuguese (BR)",
	"es": "Español",
	"it": "Italiano",
	"de": "Deutsch",
	"fr": "Français",
	"tr_TR": "Türkçe",
	"uk": "Українська",
	"apc": "اللهجة الشامية",
	"id": "Bahasa Indonesia",
}


func _ready() -> void:
	# toggle active language
	var button_group: ButtonGroup = ButtonGroup.new()
	for language_key: String in LANGUAGES.keys():
		var button: Button = DefaultButton.new()
		button.text = LANGUAGES[language_key]
		button.button_group = button_group
		button.button_pressed = Global.config.language == language_key
		button.pressed.connect(_on_button_pressed.bind(language_key))
		add_child(button)


func _on_button_pressed(language_key: String) -> void:
	Global.config.set_lang(language_key)
	Main.check_layout_direction()
	language_change.emit()
