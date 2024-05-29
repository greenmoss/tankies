extends Vision


func _ready():
    distance = 2
    update()


func update():
    if set_from_coordinate(convert_from_world_position(owner.position)):
        SignalBus.city_updated_vision.emit(owner)
