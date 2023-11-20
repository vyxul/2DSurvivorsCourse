class_name WeightedTable

var items: Array[Dictionary] = []
var weight_sum: int = 0


func add_item(item, weight: int):
	items.append({
		"item": item,
		"weight": weight
	})
	
	weight_sum += weight


func pick_item(exclude: Array = []):
	var adjusted_items: Array[Dictionary] = items
	var adjusted_weight_sum = weight_sum
	if exclude.size() > 0:
		adjusted_items = []
		adjusted_weight_sum = 0
		for item in items:
			if item["item"] in exclude:
				continue
			adjusted_items.append(item)
			adjusted_weight_sum += item["weight"]
	
	# get a random int from 1 to the highest possible value in the array we have stored
	var chosen_weight = randi_range(1, adjusted_weight_sum)
	# this is a helper variable to find the correct item
	var iteration_sum = 0
	for item in adjusted_items:
		# get the value for the item in this iteration
		iteration_sum += item["weight"]
		# if the random value falls within this items value, return this item
		if chosen_weight <= iteration_sum:
			return item["item"]

	# should be guaranteed to find the random item within the for loop, dont need a backup return value


func remove_item(item_to_remove):
	items = items.filter(func (item):
		return item["item"] != item_to_remove
	)
	weight_sum = 0
	for item in items:
		weight_sum += item["weight"]
