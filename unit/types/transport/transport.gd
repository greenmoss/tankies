extends Unit
class_name Transport

func _ready():
    attack_strength = 0
    build_time = 8
    can_capture = false
    defense_strength = 2
    fuel_capacity = 0
    fuel_remaining = 0
    haul_unit_capacity = 4
    haul_unit_type = 'land'
    moves_per_turn = 4
    vision_distance = 1

    super._ready()
