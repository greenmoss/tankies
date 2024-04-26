extends "../common/move.gd"


func enter():
    owner.state.states_vars['scout']['target_city'].capture_by(owner)
    await animate()
    owner.disband()
