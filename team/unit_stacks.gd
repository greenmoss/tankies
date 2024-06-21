extends Node

var position_stacks:Dictionary
var unit_stack_scene:PackedScene = preload("unit_stack.tscn")


func _ready():
    SignalBus.cursor_marked_unit.connect(_promote_unit)
    SignalBus.unit_changed_position.connect(_promote_unit)


func _promote_unit(unit:Unit):
    if unit.my_team != get_parent().name: return
    if unit.position not in position_stacks.keys():
        set_from_units(get_parent().units)
        if unit.position not in position_stacks.keys():
            return

    var unit_stack = position_stacks[unit.position]
    if unit_stack == null: return
    if not is_instance_valid(unit_stack): return
    if unit_stack.is_queued_for_deletion(): return

    unit_stack.promote_unit(unit)


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
