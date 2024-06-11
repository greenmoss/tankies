extends Unit
class_name Fighter

func _ready():
    attack_strength = 5
    build_time = 6
    defense_strength = 2
    moves_per_turn = 20
    vision_distance = 2

    super._ready()
