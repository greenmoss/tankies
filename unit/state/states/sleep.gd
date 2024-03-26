extends "res://common/state.gd"

func enter():
    print("in state:sleep enter")
    owner.inactive.sleep_infinity()


func handle_input(event):
    print("in state:sleep handle input: ",event)
    if event.is_action_pressed('sleep'):
        owner.inactive.awaken()
        if owner.moves_remaining > 0:
            emit_signal("finished", "idle")
        else:
            emit_signal("finished", "end")
        return


func update(_delta):
    pass
