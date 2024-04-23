extends "../common/move.gd"


func enter():
    await animate()
    reduce_moves()


func handle_input(event):
    return super.handle_input(event)
