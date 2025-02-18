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
						# elif item is Color:
						# 	parsed_array.append((item as Color).to_html(true))
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
			continue

		if property is Array:
			var array: Array[Variant] = property as Array
			var dict_array: Array = dict[key]
			# assuming all used resources are JSON resources
			# could be made more precise by checking path of get_typed_script
			if array.get_typed_class_name() == "Resource":
				var array_script: GDScript = array.get_typed_script()
				for dict_item: Variant in dict_array:
					var resource: JSONResource = array_script.new()
					resource.from_json(dict_item)
					array.append(resource)
			# built in types, without considering nested arrays
			else:
				for dict_item: Variant in dict_array:
					array.append(dict_item)

		elif property is JSONResource:
			(property as JSONResource).from_json(dict[key])
		else:
			set(key, dict[key])


