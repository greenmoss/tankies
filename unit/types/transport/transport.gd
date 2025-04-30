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


func is_free_of_obstacles(terrain_position:Vector2, world:World) -> bool:
    if terrain_position == self.position:
        return true

    var terrain_point = Global.as_grid(terrain_position)

    if terrain_point not in world.obstacles.points:
        push_warning("terrain point "+str(terrain_point)+" not found in obstacle points")
        return false

    var point_objects = world.obstacles.points[terrain_point]
    if point_objects.size() == 0:
        return true

    for obstacle in point_objects:
        # transports can not attack
        # nor move into non-owned cities
        if obstacle.my_team == self.my_team:
            return true

        return false

    push_warning("Should have decided obstacle passability already, but returning impassable just to be safe")
    return false
