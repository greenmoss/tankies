extends "../common/unit.gd"

var nearby:Unit
var elapsed = 0.0


func enter():
    if nearby == null:
        owner.want_nearest_unit.emit(owner.position)
        return

    if not is_instance_valid(nearby):
        owner.want_nearest_unit.emit(owner.position)
        return

    if nearby.is_queued_for_deletion():
        owner.want_nearest_unit.emit(owner.position)
        return

    owner.want_next_unit.emit(nearby)


func exit():
    nearby = null
    elapsed = 0.0


func update(delta):
    elapsed += delta
    # TODO: figure out why we sometimes get "stuck" here
    # then remove `elapsed`
    if elapsed > 1.0:
        emit_signal("next_state", "none")
    
