# SPDX-FileCopyrightText: 2025 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name MoneyEdit
extends Control

@export var amount: int = 0
@export var step: int = 1_000
@export var min_amount: int = 0
@export var max_amount: int = 100_000


@onready var amount_edit: LineEdit = %Amount


func _ready() -> void:
	amount_edit.text = FormatUtil.currency(amount)


func setup(
	p_amount: int = amount,
	p_min_amount: int = min_amount,
	p_max_amount: int = max_amount,
	p_step: int = step,
	) -> void:
	amount = p_amount
	step = p_step
	min_amount = p_min_amount
	max_amount = p_max_amount

	_update_amount()


func _on_amount_text_changed(new_text:String) -> void:
	amount = int(new_text)
	_update_amount()


func _on_more_pressed() -> void:
	amount += step
	_update_amount()


func _on_less_pressed() -> void:
	amount -= step
	_update_amount()


func _update_amount() -> void:
	if amount > max_amount:
		amount = max_amount
	if amount < min_amount:
		amount = min_amount

	amount_edit.text = FormatUtil.currency(amount)
