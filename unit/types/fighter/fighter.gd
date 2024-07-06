extends Unit
class_name Fighter

func _ready():
    attack_strength = 5
    build_time = 6
    can_capture = false
    defense_strength = 2
    fuel_capacity = 20
    fuel_remaining = 20
    load_unit_capacity = 0
    load_unit_type = ''
    moves_per_turn = 20
    vision_distance = 2

    super._ready()
