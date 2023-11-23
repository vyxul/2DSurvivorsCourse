extends Resource
class_name MetaUpgrade

@export var id: String
@export var max_quantity: int = 1
@export var experience_cost: int = 10
@export var upgrade_raw_per_level: int = 0
@export_range(0, 1) var upgrade_percent_per_level: float = 0
@export var title: String
@export_multiline var description: String
