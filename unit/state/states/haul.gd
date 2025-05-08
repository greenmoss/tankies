extends "../common/idle.gd"


func _ready():
    SignalBus.unit_can_haul.connect(_unit_can_haul)


func _unit_can_haul(hauler:Unit) -> void:
    if not owner.unit.state.is_hauled(): return
    if not hauler.can_haul_unit(owner.unit): return

    # it's on our position, probably in a port
    if owner.unit.position == hauler.position:
        hauler.haul_unit(owner.unit)
        return

    # might be nearby instead
    # wake up and check
    emit_signal("next_state", "idle")


func enter():
    owner.unit.display.set_hauled()


func exit():
    owner.unit.display.remove_symbol()


func handle_cursor_input(event):
    if event.is_action_pressed("click") or event.is_action_pressed('haul'):
        if not owner.unit.is_hauled():
            unhaul()
            return

        owner.unit.sounds.play_ready()

    for direction in input_directions.keys():
        if event.is_action_pressed(direction):
            owner.unit.look_direction = input_directions[direction]
            emit_signal("next_state", "scout")
            return


func unhaul():
    owner.unit.display.remove_symbol()
    if owner.unit.moves_remaining > 0:
        emit_signal("next_state", "idle")
    else:
        emit_signal("next_state", "end")
