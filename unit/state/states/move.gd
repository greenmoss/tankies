extends "../common/move.gd"


func enter():
    haul_port_units()
    await animate()
    reduce_moves()


func haul_port_units():
    if not owner.unit.can_haul(): return
    if not owner.unit.is_in_city(): return
    SignalBus.unit_can_haul.emit(owner.unit)
