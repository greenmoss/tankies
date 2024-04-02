extends "../common/idle.gd"


func enter():
    print("in state:sleep enter")
    owner.inactive.sleep_infinity()


func handle_input(event):
    print("in state:sleep handle input: ",event)

    for direction in input_directions.keys():
        if event.is_action_pressed(direction):
            print("requested direction ",direction)
            owner.sounds.play_denied()
            return

    if event.is_action_pressed('sleep'):
        owner.inactive.awaken()
        if owner.moves_remaining > 0:
            emit_signal("next_state", "idle")
        else:
            emit_signal("next_state", "end")
        return


func update(_delta):
    pass
