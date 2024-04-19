extends "../common/idle.gd"


func enter():
    #print("in state:end enter")
    #owner.get_node(^"AnimationPlayer").play("idle")
    SignalBus.unit_completed_moves.emit(owner.my_team)
    owner.sounds.stop_all()
    owner.inactive.done_moving()


func handle_input(event):
    #print("in state:end handle input: ",event)

    for direction in input_directions.keys():
        if event.is_action_pressed(direction):
            #print("requested direction ",direction)
            owner.sounds.play_denied()
            return

    if event.is_action_pressed('sleep'):
        emit_signal("next_state", "sleep")
        return
    #owner.sounds.play_denied()
    #return super.handle_input(event)


func update(_delta):
    pass
    #print("in state:idle for unit ",self,", update")
    #var input_direction = get_input_direction()
    #if input_direction:
    #    emit_signal("next_state", "move")

func exit():
    if owner.moves_remaining > 0:
        owner.inactive.awaken()
