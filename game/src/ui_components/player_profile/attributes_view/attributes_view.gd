# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name AttributesView
extends HBoxContainer

const ColorLabelScene: PackedScene = preload("res://src/ui_components/base/color_label/color_label.tscn")


func setup(player: Player) -> void:
	var attribute_names: Dictionary = player.attributes.get_all_attributes()
	for attribute: String in attribute_names.keys():
		# first remove existing values
		for child: Node in get_node(attribute.capitalize()).get_children():
			child.queue_free()

		# add title and a empty label
		var label_title: Label = Label.new()
		label_title.text = tr(attribute.to_upper())
		get_node(attribute.capitalize()).add_child(label_title)
		get_node(attribute.capitalize()).add_child(Label.new())

		for key: String in attribute_names[attribute]:
			var label: Label = Label.new()
			label.text = tr(key.to_upper())
			label.tooltip_text = tr(key.to_upper())
			#label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
			get_node(attribute.capitalize()).add_child(label)
			var attribute_value: ColorLabel = ColorLabelScene.instantiate()
			get_node(attribute.capitalize()).add_child(attribute_value)
			attribute_value.setup(key)
			attribute_value.set_value(player.get_res_value(["attributes", attribute, key]))
