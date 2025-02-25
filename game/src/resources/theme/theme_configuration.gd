# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name ThemeConfiguration
extends Resource

@export var name: String

@export var font_color: Color
@export var style_color: Color
@export var style_important_color: Color

@export var background_color: Color
@export var background_secondary_color: Color

var font_color_variation: ColorVariation
var style_color_variation: ColorVariation
var style_important_color_variation: ColorVariation


func _init(
	p_name: String = "",
	p_font_color: Color = Color.BLACK,
	p_style_color: Color = Color.RED,
	p_style_important_color: Color = Color.BLUE,
	p_background_color: Color = Color.WHITE,
	p_background_secondary_color: Color = Color.GRAY,
) -> void:
	name = p_name
	font_color = p_font_color
	style_color = p_style_color
	style_important_color = p_style_important_color
	background_color = p_background_color
	background_secondary_color = p_background_secondary_color


func setup() -> void:
	font_color_variation = ColorVariation.new(font_color)
	style_color_variation = ColorVariation.new(style_color)
	style_important_color_variation = ColorVariation.new(style_important_color)
