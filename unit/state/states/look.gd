extends "res://common/state.gd"

func enter():
    owner.ray.target_position = owner.look_direction * Global.tile_size
    owner.ray.force_raycast_update()

    if not owner.ray.is_colliding():
        emit_signal("next_state", "move")
        return

    # get all ray collision targets
    # units can be inside other units or in cities, so ray can collide with multiple
    # technique from https://forum.godotengine.org/t/27326
    var targets = []
    while owner.ray.is_colliding():
        var target = owner.ray.get_collider()
        targets.append(target)

        if target is TileMap:
            #REF
            #await deny_move()
            owner.sounds.play_denied()
            emit_signal("next_state", "idle")
            return

        owner.ray.add_exception(target)
        owner.ray.force_raycast_update()

    var target_city : Area2D = null
    var target_unit : Area2D = null
    for target in targets:
        owner.ray.remove_exception(target)
        if target.is_in_group("Cities"): target_city = target
        if target.is_in_group("Units"): target_unit = target

    if target_unit != null:
        if owner.my_team == target_unit.my_team:
            emit_signal("next_state", "move")
            return

        emit_signal("next_state", "attack")
        return

    if target_city == null:
        print("WARNING: we should have a city here, but we don't; what did the ray collide with?")

    owner.in_city = target_city
    if owner.my_team == target_city.my_team:
        emit_signal("next_state", "move")
        return

    emit_signal("next_state", "attack")
    return


func handle_input(event):
    return super.handle_input(event)


func update(_delta):
    pass
    #print("in state:move update")
    #var input_direction = get_input_direction()
    #if input_direction.is_zero_approx():
    #    emit_signal("next_state", "idle")
    #update_look_direction(input_direction)

    #REF
    #for direction in inputs.keys():
    #    if Input.is_action_pressed(direction):
    #        print("requested direction ",direction)

    #if Input.is_action_pressed("run"):
    #    speed = max_run_speed
    #else:
    #    speed = max_walk_speed

    #var collision_info = move(speed, input_direction)
    #if not collision_info:
    #    return
    #if speed == max_run_speed and collision_info.collider.is_in_group("environment"):
    #    return null


