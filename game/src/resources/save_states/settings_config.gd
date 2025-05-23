# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name SettingsConfig
extends JSONResource

@export var language: String
@export var currency: FormatUtil.Currencies
@export var date: FormatUtil.Dates
@export var audio: Dictionary
@export var input_automatic_detection: bool
@export var input_type: Enum.InputType
@export var theme_index: int
@export var theme_scale: float
@export var theme_font_size: int
@export var theme_custom_font_color: String
@export var theme_custom_style_color: String
@export var theme_custom_background_color: String
@export var scene_fade: bool


func _init(
	p_language: String = "",
	p_currency: FormatUtil.Currencies = FormatUtil.Currencies.EURO,
	p_date: FormatUtil.Dates = FormatUtil.Dates.DMY_SLASH,
	p_audio: Dictionary = {},
	p_input_automatic_detection: bool = true,
	p_input_type: Enum.InputType = Enum.InputType.MOUSE_AND_KEYBOARD,
	p_theme_index: int = 0,
	p_theme_scale: float = ThemeUtil.get_default_scale(),
	p_theme_font_size: int = Const.FONT_SIZE_DEFAULT,
	p_theme_custom_font_color: String = Color.BLACK.to_html(true),
	p_theme_custom_style_color: String = Color.RED.to_html(true),
	p_theme_custom_background_color: String = Color.WHITE.to_html(true),
	p_scene_fade: bool = true,
) -> void:
	language = p_language
	currency = p_currency
	date = p_date
	audio = p_audio
	input_automatic_detection = p_input_automatic_detection
	input_type = p_input_type
	theme_index = p_theme_index
	theme_scale = p_theme_scale
	theme_font_size = p_theme_font_size
	theme_custom_font_color = p_theme_custom_font_color
	theme_custom_style_color = p_theme_custom_style_color
	theme_custom_background_color = p_theme_custom_background_color
	scene_fade = p_scene_fade


func set_lang(lang: String) -> void:
	TranslationServer.set_locale(lang)
	language = lang
	DataUtil.save_config()

