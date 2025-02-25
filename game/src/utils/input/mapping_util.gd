# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name Mapping

# default unicode characters

const BUTTON: Dictionary = {
	JoypadUtil.Type.PLAYSTATION:
	{
		JOY_BUTTON_A: "X",  # cross
		JOY_BUTTON_B: "O",  # circle
		JOY_BUTTON_X: "[ ]",  # square
		JOY_BUTTON_Y: "^",  # triangle
		JOY_BUTTON_LEFT_SHOULDER: "L1",  # l1
		JOY_BUTTON_RIGHT_SHOULDER: "R1",  # r1
		JOY_BUTTON_START: "START",  # start
		JOY_BUTTON_BACK: "SELECT",  # select
	},
	JoypadUtil.Type.XBOX:
	{
		JOY_BUTTON_A: "A",  # a
		JOY_BUTTON_B: "b",  # b
		JOY_BUTTON_X: "X",  # x
		JOY_BUTTON_Y: "Y",  # y
		JOY_BUTTON_LEFT_SHOULDER: "LB",  # lb
		JOY_BUTTON_RIGHT_SHOULDER: "RB",  # rb
		JOY_BUTTON_START: "START",  # start
		JOY_BUTTON_BACK: "SELECT",  # select
	},
	JoypadUtil.Type.NINTENDO:
	{
		JOY_BUTTON_A: "A",  # b
		JOY_BUTTON_B: "B",  # a
		JOY_BUTTON_X: "Y",  # y
		JOY_BUTTON_Y: "X",  # x
		JOY_BUTTON_LEFT_SHOULDER: "L",  # l
		JOY_BUTTON_RIGHT_SHOULDER: "R",  # r
		JOY_BUTTON_START: "START",  # start
		JOY_BUTTON_BACK: "SELECT",  # select
	},
	JoypadUtil.Type.GENERIC:
	{
		JOY_BUTTON_A: "1",  # 1
		JOY_BUTTON_B: "2",  # 2
		JOY_BUTTON_X: "3",  # 3
		JOY_BUTTON_Y: "4",  # 4
		JOY_BUTTON_LEFT_SHOULDER: "5",  # 5
		JOY_BUTTON_RIGHT_SHOULDER: "6",  # 6
		JOY_BUTTON_START: "START",  # start
		JOY_BUTTON_BACK: "SELECT",  # select
	},
}

const AXIS: Dictionary = {
	JoypadUtil.Type.PLAYSTATION:
	{
		JOY_AXIS_TRIGGER_LEFT: "R2",  # r2
		JOY_AXIS_TRIGGER_RIGHT: "L2",  # l2
	},
	JoypadUtil.Type.XBOX:
	{
		JOY_AXIS_TRIGGER_LEFT: "LT",  # lt
		JOY_AXIS_TRIGGER_RIGHT: "RT",  # rt
	},
	JoypadUtil.Type.NINTENDO:
	{
		JOY_AXIS_TRIGGER_LEFT: "ZL",  # zl
		JOY_AXIS_TRIGGER_RIGHT: "ZR",  # zr
	},
	JoypadUtil.Type.GENERIC:
	{
		JOY_AXIS_TRIGGER_LEFT: "7",  # 7
		JOY_AXIS_TRIGGER_RIGHT: "8",  # 8
	},
}

# font glyphs

const BUTTON_GLYPHS: Dictionary = {
	JoypadUtil.Type.PLAYSTATION:
	{
		JOY_BUTTON_A: "\u21E3",  # cross
		JOY_BUTTON_B: "\u21E2",  # circle
		JOY_BUTTON_X: "\u21E0",  # square
		JOY_BUTTON_Y: "\u21E1",  # triangle
		JOY_BUTTON_LEFT_SHOULDER: "\u21B0",  # l1
		JOY_BUTTON_RIGHT_SHOULDER: "\u21B1",  # r1
		JOY_BUTTON_START: "START",  # start
		JOY_BUTTON_BACK: "SELECT",  # select
	},
	JoypadUtil.Type.XBOX:
	{
		JOY_BUTTON_A: "\u21D3",  # a
		JOY_BUTTON_B: "\u21D2",  # b
		JOY_BUTTON_X: "\u21D0",  # x
		JOY_BUTTON_Y: "\u21D1",  # y
		JOY_BUTTON_LEFT_SHOULDER: "\u2198",  # lb
		JOY_BUTTON_RIGHT_SHOULDER: "\u2199",  # rb
		JOY_BUTTON_START: "START",  # start
		JOY_BUTTON_BACK: "SELECT",  # select
	},
	JoypadUtil.Type.NINTENDO:
	{
		JOY_BUTTON_A: "\u21D2",  # b
		JOY_BUTTON_B: "\u21D3",  # a
		JOY_BUTTON_X: "\u21D1",  # y
		JOY_BUTTON_Y: "\u21D0",  # x
		JOY_BUTTON_LEFT_SHOULDER: "\u219C",  # l
		JOY_BUTTON_RIGHT_SHOULDER: "\u219D",  # r
		JOY_BUTTON_START: "START",  # start
		JOY_BUTTON_BACK: "SELECT",  # select
	},
	JoypadUtil.Type.GENERIC:
	{
		JOY_BUTTON_A: "\u24F5",  # 1
		JOY_BUTTON_B: "\u24F6",  # 2
		JOY_BUTTON_X: "\u24F7",  # 3
		JOY_BUTTON_Y: "\u24F8",  # 4
		JOY_BUTTON_LEFT_SHOULDER: "\u24F9",  # 5
		JOY_BUTTON_RIGHT_SHOULDER: "\u24FA",  # 6
		JOY_BUTTON_START: "START",  # start
		JOY_BUTTON_BACK: "SELECT",  # select
	},
}

const AXIS_GLYPHS: Dictionary = {
	JoypadUtil.Type.PLAYSTATION:
	{
		JOY_AXIS_TRIGGER_LEFT: "\u21B2",  # r2
		JOY_AXIS_TRIGGER_RIGHT: "\u21B3",  # l2
	},
	JoypadUtil.Type.XBOX:
	{
		JOY_AXIS_TRIGGER_LEFT: "\u2196",  # lt
		JOY_AXIS_TRIGGER_RIGHT: "\u2197",  # rt
	},
	JoypadUtil.Type.NINTENDO:
	{
		JOY_AXIS_TRIGGER_LEFT: "\u219A",  # zl
		JOY_AXIS_TRIGGER_RIGHT: "\u219B",  # zr
	},
	JoypadUtil.Type.GENERIC:
	{
		JOY_AXIS_TRIGGER_LEFT: "\u24F6B",  # 7
		JOY_AXIS_TRIGGER_RIGHT: "\u24FC",  # 8
	},
}

# icons

const BUTTON_ICONS: Dictionary = {
	JoypadUtil.Type.PLAYSTATION:
	{
		JOY_BUTTON_A: preload("res://assets/joypad_glyphs/button-cross.png"),  # cross
		JOY_BUTTON_B: preload("res://assets/joypad_glyphs/button-circle.png"),  # circle
		JOY_BUTTON_X: preload("res://assets/joypad_glyphs/button-square.png"),  # square
		JOY_BUTTON_Y: preload("res://assets/joypad_glyphs/button-triangle.png"),  # triangle
		JOY_BUTTON_LEFT_SHOULDER: preload("res://assets/joypad_glyphs/L1.png"),  # l1
		JOY_BUTTON_RIGHT_SHOULDER: preload("res://assets/joypad_glyphs/R1.png"),  # r1
		JOY_BUTTON_START: preload("res://assets/joypad_glyphs/start.png"),  # start
		JOY_BUTTON_BACK: preload("res://assets/joypad_glyphs/select.png"),  # select
	},
	JoypadUtil.Type.XBOX:
	{
		JOY_BUTTON_A: "\u21D3",  # a
		JOY_BUTTON_B: "\u21D2",  # b
		JOY_BUTTON_X: "\u21D0",  # x
		JOY_BUTTON_Y: "\u21D1",  # y
		JOY_BUTTON_LEFT_SHOULDER: "\u2198",  # lb
		JOY_BUTTON_RIGHT_SHOULDER: "\u2199",  # rb
		JOY_BUTTON_START: "START",  # start
		JOY_BUTTON_BACK: "SELECT",  # select
	},
	JoypadUtil.Type.NINTENDO:
	{
		JOY_BUTTON_A: "\u21D2",  # b
		JOY_BUTTON_B: "\u21D3",  # a
		JOY_BUTTON_X: "\u21D1",  # y
		JOY_BUTTON_Y: "\u21D0",  # x
		JOY_BUTTON_LEFT_SHOULDER: "\u219C",  # l
		JOY_BUTTON_RIGHT_SHOULDER: "\u219D",  # r
		JOY_BUTTON_START: "START",  # start
		JOY_BUTTON_BACK: "SELECT",  # select
	},
	JoypadUtil.Type.GENERIC:
	{
		JOY_BUTTON_A: "\u24F5",  # 1
		JOY_BUTTON_B: "\u24F6",  # 2
		JOY_BUTTON_X: "\u24F7",  # 3
		JOY_BUTTON_Y: "\u24F8",  # 4
		JOY_BUTTON_LEFT_SHOULDER: "\u24F9",  # 5
		JOY_BUTTON_RIGHT_SHOULDER: "\u24FA",  # 6
		JOY_BUTTON_START: "START",  # start
		JOY_BUTTON_BACK: "SELECT",  # select
	},
}

const AXIS_ICONS: Dictionary = {
	JoypadUtil.Type.PLAYSTATION:
	{
		JOY_AXIS_TRIGGER_LEFT: preload("res://assets/joypad_glyphs/L2.png"),  # l2
		JOY_AXIS_TRIGGER_RIGHT: preload("res://assets/joypad_glyphs/R2.png"),  # r2
	},
	JoypadUtil.Type.XBOX:
	{
		JOY_AXIS_TRIGGER_LEFT: "\u2196",  # lt
		JOY_AXIS_TRIGGER_RIGHT: "\u2197",  # rt
	},
	JoypadUtil.Type.NINTENDO:
	{
		JOY_AXIS_TRIGGER_LEFT: "\u219A",  # zl
		JOY_AXIS_TRIGGER_RIGHT: "\u219B",  # zr
	},
	JoypadUtil.Type.GENERIC:
	{
		JOY_AXIS_TRIGGER_LEFT: "\u24F6B",  # 7
		JOY_AXIS_TRIGGER_RIGHT: "\u24FC",  # 8
	},
}
