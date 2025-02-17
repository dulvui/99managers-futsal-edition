# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name JSONResource
extends Resource


var has_changed: bool


func to_json() -> Dictionary:
	var data: Dictionary = {}

	# only add export vars to dictionary
	var property_list: Array[Dictionary] = get_property_list()
	for property: Dictionary in property_list:
		if property.usage == Const.CUSTOM_PROPERTY_EXPORT:
			var property_name: String = property.name
			var value: Variant = get(property_name)
			if value != null:
				if value is Array:
					var parsed_array: Array = []
					var array: Array = (value as Array)
					for item: Variant in array:
						if item is JSONResource:
							parsed_array.append((item as JSONResource).to_json())
						else:
							parsed_array.append(item)
					data[property_name] = parsed_array
				elif value is JSONResource:
					data[property_name] = (value as JSONResource).to_json()
				else:
					data[property_name] = value
	return data


func from_json(dict: Dictionary) -> void:
	for key: String in dict.keys():
		var property: Variant = get(key)

		if property == null:
			print("property with name %s not found" % key)
			return

		if property is JSONResource:
			return

		if property is Array:
			return

		set(key, dict[key])


