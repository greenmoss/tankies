extends "res://common/state.gd"

func enter():
    print("in state:collide enter")
    #owner.get_node(^"AnimationPlayer").play("idle")


func handle_input(event):
    print("in state:collide handle input: ",event)
    #return super.handle_input(event)


func update(_delta):
    pass
    #print("in state:idle for unit ",self,", update")
    #var input_direction = get_input_direction()
    #if input_direction:
    #    emit_signal("next_state", "move")
