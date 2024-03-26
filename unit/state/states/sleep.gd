extends "res://common/state.gd"

func enter():
    print("in state:sleep enter")


func handle_input(event):
    print("in state:sleep handle input: ",event)


func update(_delta):
    pass
