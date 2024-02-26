extends 'team.gd'

class_name AiTeam

# when the human team is moving, we are paused
var paused: bool
var selected_unit: Area2D

# AI targets this team's units
@export var enemy_units: Node

func pause():
    selected_unit = null
    paused = true

func move():
    paused = false
    if selected_unit == null:
        selected_unit = units.get_next()
        assign_move(selected_unit)

func assign_move(unit):
    if unit.is_moving():
        await unit.finished_movement

    var enemy_unit: Area2D = enemy_units.get_first()
    if enemy_unit == null:
        unit.reduce_moves()
        return

    var move_direction: Vector2 = (selected_unit.position - enemy_unit.position).normalized()
    print("ai team moving unit ",selected_unit, " at coords ",unit.position, " to attack unit ",enemy_unit, " at coords ",enemy_unit.position, "at direction ",move_direction)
    if(move_direction[0] > 0):
        unit.request_move("left")
        selected_unit = null
        return
    if(move_direction[1] > 0):
        unit.request_move("up")
        selected_unit = null
        return
    if(move_direction[0] < 0):
        unit.request_move("right")
        selected_unit = null
        return
    if(move_direction[1] < 0):
        unit.request_move("down")
        selected_unit = null
        return
