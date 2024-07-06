extends Unit
class_name Tank

func _ready():
    attack_strength = 4
    build_time = 4
    can_capture = true
    defense_strength = 2
    fuel_capacity = 0
    fuel_remaining = 0
    load_unit_capacity = 0
    load_unit_type = ''
    moves_per_turn = 2
    vision_distance = 1

    super._ready()
