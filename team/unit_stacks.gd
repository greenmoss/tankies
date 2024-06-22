extends Node

var position_stacks:Dictionary
var unit_stack_scene:PackedScene = preload("unit_stack.tscn")


func promote_unit(unit:Unit):
    if not verify_stack(unit.position): return
    position_stacks[unit.position].promote_unit(unit)


func remove_from_stack(unit_position:Vector2, unit:Unit):
    if not verify_stack(unit.position): return
    position_stacks[unit_position].remove_unit(unit)


func reset():
    for unit_stack in get_children():
        unit_stack.queue_free()


# ideally this runs only once
# parent/team runs this, instad of running from _ready
# because this is a child node that does not know about units during _ready
func set_from_units(units:Units):
    position_stacks = {}

    if units != null:
        var position_units = units.get_by_position()
        for position in position_units:
            set_stack(position_units[position])

    for unit_stack in get_children():
        if unit_stack.position in position_stacks.keys(): continue
        unit_stack.queue_free()


func set_stack(units:Array[Unit]):
    if units.size() < 2: return
    var unit = units[0]
    if unit.is_in_city(): return

    for unit_stack in get_children():
        if unit_stack.position != unit.position: continue
        unit_stack.set_units(units)
        unit_stack.set_info()
        position_stacks[unit.position] = unit_stack
        return

    var unit_stack:UnitStack = unit_stack_scene.instantiate()
    unit_stack.set_units(units)
    add_child(unit_stack)
    position_stacks[unit_stack.position] = unit_stack


func verify_stack(stack_position:Vector2) -> bool:
    if stack_position not in position_stacks.keys(): return false
    if not is_instance_valid(position_stacks[stack_position]):
        position_stacks.erase(stack_position)
        return false
    if position_stacks[stack_position].is_queued_for_deletion():
        position_stacks.erase(stack_position)
        return false
    return true
