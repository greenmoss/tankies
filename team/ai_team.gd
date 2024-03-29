extends 'team.gd'

class_name AiTeam

# when the human team is moving, we are paused
var paused: bool
var selected_unit: Area2D

func _ready():
    super._ready()
    pause()

func pause():
    selected_unit = null
    paused = true

# asynchronous, thus assume repeated stacking calls
# set flags to exit as needed
func move():
    paused = false

    if selected_unit == null:
        selected_unit = units.get_next()

        # no active units, so pause ai
        if selected_unit == null:
            pause()
            return

    if not is_instance_valid(selected_unit):
        selected_unit = null
        return

    if selected_unit.is_queued_for_deletion():
        selected_unit = null
        return

    if not selected_unit.has_more_moves():
        selected_unit = null
        return

    await run_ai_single_move(selected_unit)

func run_ai_single_move(unit):
    var move_target: Area2D = await enemy_units.get_first()

    # temporary until we get city attack logic
    if move_target == null:
        await unit.reduce_moves()
        unit._path.clear()
        return

    # these two can happen after a battle where the target was destroyed
    # consider the move invalid and try again
    if not is_instance_valid(move_target):
        return
    if move_target.is_queued_for_deletion():
        return
    if move_target.is_fighting():
        return

    if not terrain.is_point_walkable(move_target.position):
        await unit.reduce_moves()
        return

    if unit._path.is_empty():
        unit._path = terrain.find_path(unit.position, move_target.position)

    # target disappeared, so recalculate
    if not is_instance_valid(move_target):
        unit._path.clear()
        return

    # target moved, so recalculate
    if move_target.position != unit._path[-1]:
        unit._path.clear()
        return

    if unit.position == unit._path[0]:
        unit._path.remove_at(0)

    # reached end of path, so recalculate
    if unit._path.is_empty():
        return

    var move_direction: Vector2 = (unit.position - unit._path[0]).normalized()

    var move_text = ''
    if(move_direction[0] > 0):
        move_text = "left"
    elif(move_direction[1] > 0):
        move_text = "up"
    elif(move_direction[0] < 0):
        move_text = "right"
    elif(move_direction[1] < 0):
        move_text = "down"
    await unit.request_move(move_text)

    if unit.is_moving():
        await unit.finished_movement

    if unit.is_fighting():
        await SignalBus.battle_finished
