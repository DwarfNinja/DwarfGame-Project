extends Node

var dictionary = {"hello": 3, "goodbye": 1,"my_nameis": 2}
var arrayOfKeyValuePairs: Array = [] # array of pairs, each pair is an array with 2 elements: [key, value]
var sorted_dictionary = {}

func _process(delta):
	if Input.is_action_just_pressed("ui_down"):
		convert_to_list()
		
	if Input.is_action_just_pressed("ui_up"):
		arrayOfKeyValuePairs.sort_custom(self, "sort_list")
		print("SORTED_LIST = ", arrayOfKeyValuePairs)
		
	if Input.is_action_just_pressed("ui_right"):
		convert_to_dictionary()
	
	if Input.is_action_just_pressed("ui_left"):
		var points_dir = {"White": 50, "Yellow": 75, "Orange": 100}
		points_dir["Blue"] = 150 # Add "Blue" as a key and assign 150 as its value.
		print(points_dir)

func convert_to_list():
	for key in dictionary:
		var keyValuePair: Array = [key, dictionary[key]]
		arrayOfKeyValuePairs.append(keyValuePair)
	print("DIC_TO_LIST = ", arrayOfKeyValuePairs)
	
func sort_list(a, b):
	if a[1] > b[1]:
		return true
	return false
	
func convert_to_dictionary():
	for i in arrayOfKeyValuePairs:
		var key = i[0]
		var value = i[1]
		sorted_dictionary[key] = value
		print(sorted_dictionary)
	print("LIST_TO_DIC = ", sorted_dictionary)
