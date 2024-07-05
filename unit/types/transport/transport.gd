extends Unit
class_name Transport

func _ready():
    attack_strength = 0
    build_time = 8
    can_capture = false
    defense_strength = 2
    moves_per_turn = 6
    vision_distance = 1
    fuel_capacity = 0
    fuel_remaining = 0

    super._ready()
