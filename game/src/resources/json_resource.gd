# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name JSONResource
extends Resource


func to_json() -> Dictionary:
	var data: Dictionary = {}

	# only add export vars to dictionary
	var property_list: Array[Dictionary] = get_property_list()
	for property: Dictionary in property_list:
		# only convert properties with @export annotation
		# enums have own flag
		if (
			property.usage != Const.CUSTOM_PROPERTY_EXPORT
			and property.usage != Const.CUSTOM_PROPERTY_EXPORT_ENUM
		):
			continue

		var property_name: String = property.name
		var value: Variant = get(property_name)

		if value == null:
			continue

		if value is Array:
			var array: Array = value

			if array.size() == 0:
				continue

			data[property_name] = array.map(
				func(item: Variant) -> Variant:
					if item is JSONResource:
						var json_resource: JSONResource = item
						return json_resource.to_json()
					return item
			)

		elif value is JSONResource:
			var json_resource: JSONResource = value
			data[property_name] = json_resource.to_json()

		else:
			data[property_name] = value

	return data


func from_json(dict: Dictionary) -> void:
	for key: String in dict.keys():
		var property: Variant = get(key)

		if property == null:
			continue

		# Arrays
		if property is Array:
			var array: Array[Variant] = property

			var dict_array: Array = dict[key]
			if dict_array.size() == 0:
				continue

			# assuming all used resources are JSON resources
			# could be made more precise by checking path of get_typed_script
			var array_script: GDScript = array.get_typed_script()
			if array_script != null:
				array.append_array(
					dict_array.map(func(dict_item: Variant) -> Variant:
					var resource: JSONResource = array_script.new()
					var dictionary: Dictionary = dict_item
					resource.from_json(dictionary)
					return resource
					)
				)

			# built in types, without considering nested arrays
			else:
				var array_type: int = array.get_typed_builtin()
				array.append_array(
					dict_array.map(func(dict_item: Variant) -> Variant:
					return type_convert(dict_item, array_type)
					)
				)

		# JSONResource
		elif property is JSONResource:
				var json_resource: JSONResource = property
				var dictionary: Dictionary = dict[key]
				json_resource.from_json(dictionary)

		# other built in types
		else:
			set(key, dict[key])

