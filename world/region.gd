extends Node
class_name Region

var id:int
var colliders:int # collision layers: what unit types can traverse this region
var positions:Array[Vector2i]
var terrain_id:int
var terrain_type:String
var max_bound:Vector2i
var min_bound:Vector2i


func _ready():
    positions = []
    # can not be null, so use opposite max/min instead
    max_bound = Vector2i.MIN
    min_bound = Vector2i.MAX


func add_position(new_position:Vector2i):
    if new_position in positions: return
    positions.append(new_position)
    if new_position.x > max_bound.x:
        max_bound.x = new_position.x
    if new_position.y > max_bound.y:
        max_bound.y = new_position.y
    if new_position.x < min_bound.x:
        min_bound.x = new_position.x
    if new_position.y < min_bound.y:
        min_bound.y = new_position.y


func get_max_distance() -> int:
    var size_x = max_bound.x - min_bound.x
    var size_y = max_bound.y - min_bound.y
    if size_x <= 0 or size_y <= 0:
        return 0
    if size_x > size_y:
        return size_x
    return size_y


func set_id(new_id:int):
    id = new_id
    name = 'region'+str(id)
