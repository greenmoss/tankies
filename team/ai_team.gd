extends 'team.gd'

class_name AiTeam

# when the human team is moving, we are paused
var paused: bool
var selected_unit: Area2D

func pause():
    selected_unit = null
    paused = true

func move():
    paused = false
    if selected_unit == null:
        selected_unit = units.get_next()
        print("ai team selected unit ",selected_unit)
