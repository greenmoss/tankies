extends Unit
class_name Tank

func _ready():
    attack_strength = 4
    build_time = 4
    defense_strength = 2
    moves_per_turn = 2
    vision_distance = 1

    super._ready()
