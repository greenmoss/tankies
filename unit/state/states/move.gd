extends "../common/move.gd"


func enter():
    await animate()
    reduce_moves()
