extends Sprite2D


func set_from_direction():
    # if it's 0, we moved up or down
    # so maintain current facing
    match int(owner.look_direction.x):
        -1:
            flip_h = true
        1:
            flip_h = false


func set_from_city():
    if owner.in_city == null:
        set_full()
        return

    if owner.position != owner.in_city.position:
        push_warning("WARNING: unit is in a city, but city position doesn't match unit position; minifying anyway")

    set_mini()


func set_mini():
    scale = Vector2(0.05, 0.05)
    # TODO: derive these from sprite/size properties instead of hard coding -10, etc
    position = Vector2(-10, 10)


func set_full():
    scale = Vector2(0.07, 0.07)
    position = Vector2(0, 0)
