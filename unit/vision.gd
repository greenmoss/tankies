extends Vision


func _ready():
    distance = 1
    update()


func update():
    if set_from_coordinate(convert_from_world_position(owner.position)):
        SignalBus.unit_updated_vision.emit(owner)
