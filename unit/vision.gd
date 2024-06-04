extends Vision


func set_distance(new_distance):
    distance = new_distance
    update()


func update():
    if set_from_coordinate(convert_from_world_position(owner.position)):
        SignalBus.unit_updated_vision.emit(owner)
