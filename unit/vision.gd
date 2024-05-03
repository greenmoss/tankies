extends Node

var distance = 1
var positions:Array[Vector2]


func _ready():
    update()


func update():
    var view_position = owner.position
    var new_positions:Array[Vector2] = []
    # convert from global position to array position
    # since this is the format within a TileMap layer
    view_position.x = ceil(view_position.x / Global.tile_size)
    view_position.y = ceil(view_position.y / Global.tile_size)
    for x_offset in range(-1*distance, distance+1):
        for y_offset in range(-1*distance, distance+1):
            new_positions.append(Vector2(view_position.x + x_offset, view_position.y + y_offset))

    if positions == new_positions:
        return
    positions = new_positions
    SignalBus.unit_updated_vision.emit(owner)
