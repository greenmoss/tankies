extends "../common/move.gd"


func enter():
    owner.target_city.capture_by(owner)
    await animate()
    owner.disband()
