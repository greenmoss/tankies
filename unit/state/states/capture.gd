extends "../common/move.gd"


func enter():
    owner.state.scout.target_city.capture_by(owner)
    await animate()
    owner.disband()
