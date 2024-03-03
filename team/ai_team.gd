extends 'team.gd'

class_name AiTeam

# when the human team is moving, we are paused
var paused: bool
var selected_unit: Area2D

# AI targets this team's units
@export var enemy_units: Node

@export var _tile_map: TileMap

func pause():
    selected_unit = null
    paused = true

func move():
    paused = false
    if selected_unit == null:
        selected_unit = units.get_next()
        # no active units, so pause ai
        if selected_unit == null:
            pause()
            return
        await run_ai_moves(selected_unit)

func run_ai_moves(unit):
    while unit.has_more_moves():
        await run_ai_single_move(unit)
        if not is_instance_valid(unit): break
        if unit.is_queued_for_deletion(): break
    selected_unit = null

func run_ai_single_move(unit):

    var move_target: Area2D = await enemy_units.get_first()

    # temporary until we get city attack logic
    if move_target == null:
        await unit.reduce_moves()
        unit._path.clear()
        return

    if not _tile_map.is_point_walkable(move_target.position):
        await unit.reduce_moves()
        return

    if unit._path.is_empty():
        unit._path = _tile_map.find_path(unit.position, move_target.position)

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

func move_next_unit():
    move()
