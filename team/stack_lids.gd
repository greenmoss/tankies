extends Node

var position_stacks:Dictionary
var stack_lid_scene:PackedScene = preload("stack_lid.tscn")


func promote_unit(unit:Unit):
    if not verify_stack(unit.position): return
    position_stacks[unit.position].promote_unit(unit)


func remove_from_stack(unit_position:Vector2, unit:Unit):
    if not verify_stack(unit.position): return
    position_stacks[unit_position].remove_unit(unit)


func reset():
    for stack_lid in get_children():
        stack_lid.queue_free()


# ideally this runs only once
# parent/team runs this, instad of running from _ready
# because this is a child node that does not know about units during _ready
func set_from_units(units:Units):
    position_stacks = {}

    if units != null:
        var position_units = units.get_by_position()
        for position in position_units:
            set_stack(position_units[position])

    for stack_lid in get_children():
        if stack_lid.position in position_stacks.keys(): continue
        stack_lid.queue_free()


func set_stack(units:Array[Unit]):
    if units.size() < 2: return
    var unit = units[0]
    if unit.is_in_city(): return

    for stack_lid in get_children():
        if stack_lid.position != unit.position: continue
        stack_lid.set_units(units)
        stack_lid.set_info()
        position_stacks[unit.position] = stack_lid
        return

    var stack_lid:StackLid = stack_lid_scene.instantiate()
    stack_lid.set_units(units)
    add_child(stack_lid)
    Global.set_z(stack_lid, 'stack_lid')
    position_stacks[stack_lid.position] = stack_lid


func verify_stack(stack_position:Vector2) -> bool:
    if stack_position not in position_stacks.keys(): return false
    if not is_instance_valid(position_stacks[stack_position]):
        position_stacks.erase(stack_position)
        return false
    if position_stacks[stack_position].is_queued_for_deletion():
        position_stacks.erase(stack_position)
        return false
    return true
