extends "../common/move.gd"


func enter():
    owner.unit.state.scout.target_city.capture_by(owner.unit)
    await animate()
    owner.unit.disband()
