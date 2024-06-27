extends Node
class_name Region

var id:int
var positions:Array[Vector2i]
var terrain_type:String


func _ready():
    positions = []


func add_position(new_position:Vector2i):
    if new_position in positions: return
    positions.append(new_position)


func set_id(new_id:int):
    id = new_id
    name = 'region'+str(id)
