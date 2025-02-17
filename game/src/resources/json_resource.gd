# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name JSONResource
extends Resource


func to_json() -> Dictionary:
	var dict: Dictionary = {}
	var property_list: Array[Dictionary] = get_property_list()

	for property: Dictionary in property_list:
		if property.usage == Const.CUSTOM_PROPERTY_EXPORT:
			var property_name: String = property.name
			# get value from resurce itself to guess type
			var value: Variant = get(property_name)

			if _is_primitive(value):
				dict[property_name] = value
			elif value is JSONResource:
				var d: Dictionary = (value as JSONResource).to_json()
				dict[property_name] = d
			elif typeof(value) == Variant.Type.TYPE_ARRAY:
				var array: Array = []
				for item: Variant in value as Array:
					if _is_primitive(item):
						array.append(item)
					elif typeof(item) == Variant.Type.TYPE_OBJECT:
						if item is JSONResource:
							var d: Dictionary = (item as JSONResource).to_json()
							array.append(d)
				dict[property_name] = array
	return dict


func from_json(json: Dictionary) -> JSONResource:
	var property_list: Array[Dictionary] = get_property_list()
	for property: Dictionary in property_list:
		# if property.usage == Const.CUSTOM_PROPERTY or property.usage == Const.CUSTOM_PROPERTY_EXPORT:
		if property.usage == Const.CUSTOM_PROPERTY_EXPORT:
			var property_name: String = property.name
			var value: Variant = get(property_name)
			var json_value: Variant = json.get(property_name)

			if _is_primitive(value):
				set(property_name, json_value)
			elif typeof(value) == Variant.Type.TYPE_OBJECT:
				if value is JSONResource:
					var json_resource: JSONResource = (value as JSONResource).from_json(json_value)
					set(property_name, json_resource)
			elif typeof(value) == Variant.Type.TYPE_ARRAY:
				var array: Array = []
				for item: Variant in json_value:
					if _is_primitive(value):
						array.append(item)
					elif typeof(item) == Variant.Type.TYPE_OBJECT:
						if item is JSONResource:
							var json_resource: JSONResource = (value as JSONResource).from_json(json_value)
							array.append(json_resource)
						else:
							print("JSONResource error, array not supported object with name: " + property_name)
				set(property_name, array)
	return self


func _is_primitive(variant: Variant) -> bool:
	if typeof(variant) < 5:
		return true
	if typeof(variant) == Variant.Type.TYPE_DICTIONARY:
		return true
	if typeof(variant) == Variant.Type.TYPE_STRING_NAME:
		return true
	return false


# func is_safe_to_parse() -> void:
	# var global_class_list: Array[Dictionary] = ProjectSettings.get_global_class_list()
	# # TODO move to global to not create on every parse
	#
	# var json_resource_class_list: Array = (
	# 	global_class_list
	# 	. filter(
	# 		func(d: Dictionary) -> bool: return (
	# 			str(d.path).begins_with("res://") and d.base == "JSONResource"
	# 		)
	# 	)
	# 	. map(func(d: Dictionary) -> String: return d.class)
	# )
	#
	# var json_resource_class_list_copy: Array = json_resource_class_list.duplicate(true)
	# while not json_resource_class_list_copy.is_empty():
	# 	json_resource_class_list_copy = (
	# 		global_class_list
	# 		. filter(
	# 			func(d: Dictionary) -> bool: return (
	# 				str(d.path).begins_with("res://") and d.base in json_resource_class_list_copy
	# 			)
	# 		)
	# 		. map(func(d: Dictionary) -> String: return d.class)
	# 	)
	# 	json_resource_class_list.append_array(json_resource_class_list_copy)

