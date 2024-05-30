extends "../common/unit.gd"


func enter():
    owner.want_nearest_unit.emit(owner.position)
