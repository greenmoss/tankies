extends 'team.gd'

class_name HumanTeam

func move():
    move_next_unit()

func move_next_unit():
    units.select_next()
