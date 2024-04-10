extends "../common/idle.gd"


func enter():
    #print("in state:idle enter")
    #REF new intermediate state for "clicked on"?
    if owner.sounds != null:
        print("playing ready")
        owner.sounds.play_ready()
    #owner.get_node(^"AnimationPlayer").play("idle")
    owner.became_idle.emit()


func handle_input(event):
    #print("in state:idle handle input: ",event)
    for direction in input_directions.keys():
        if event.is_action_pressed(direction):
            #print("requested direction ",direction)
            owner.look_direction = input_directions[direction]
            emit_signal("next_state", "move")
            return

    if event.is_action_pressed('sleep'):
        emit_signal("next_state", "sleep")
        return
    #return super.handle_input(event)

func update(_delta):
    pass
    #print("in state:idle for unit ",self,", update")
    #var input_direction = get_input_direction()
    #if input_direction:
    #    emit_signal("next_state", "move")
