extends "res://common/state.gd"

var battle:Battle
var movement_tween: Tween
var move_animation_speed = 7.5


func exit():
    owner.unit.vision.update()
    SignalBus.unit_moved_to_position.emit(owner.unit, owner.unit.position)


func animate():
    owner.unit.sounds.play_move()

    movement_tween = create_tween()
    movement_tween.tween_property(owner.unit, "position",
        owner.unit.position +
        owner.unit.look_direction * Global.tile_size,
        1.0/move_animation_speed
        ).set_trans(Tween.TRANS_SINE)
    await movement_tween.finished

    if(owner.unit.in_city != null):
        # moved out of city
        if(owner.unit.position != owner.unit.in_city.position):
            owner.unit.in_city = null

        owner.unit.display.set_from_city()


func reduce_fuel():
    if not owner.unit.has_fuel():
        push_warning("can not reduce fuel on units without fuel; ignoring")

    if(owner.unit.in_city == null):
        owner.unit.fuel_remaining -=1

    else:
        owner.unit.refuel()
        # refueling takes an extra turn
        owner.unit.moves_remaining -= 1


func reduce_moves():
    if owner.unit.has_fuel():
        reduce_fuel()

        if owner.unit.fuel_remaining <= 0:
            emit_signal("next_state", "crash")
            return

    owner.unit.moves_remaining -= 1

    if owner.unit.is_loaded():
        emit_signal("next_state", "haul")
        return

    if owner.unit.moves_remaining <= 0:
        emit_signal("next_state", "end")
        return

    emit_signal("next_state", "idle")
