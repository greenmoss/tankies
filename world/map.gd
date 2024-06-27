extends Node2D
class_name Map

@onready var regions = $regions
@onready var terrain = $Terrain


func _ready():
    set_regions()
    join_ports()
    for this_position in regions.by_position.keys():
        print(this_position,': ',regions.by_position[this_position])


func get_in_bounds_neighbors(this_position) -> Array[Vector2i]:
    var neighbors:Array[Vector2i] = []
    for neighbor_position in get_neighbors(this_position):
        # max is off by one again?
        if neighbor_position.x > terrain.x_max - 1: continue
        if neighbor_position.x < terrain.x_min: continue
        if neighbor_position.y > terrain.y_max - 1: continue
        if neighbor_position.y < terrain.y_min: continue
        neighbors.append(neighbor_position)
    return(neighbors)


func get_neighbors(this_position) -> Array[Vector2i]:
    return([this_position + Vector2i.LEFT, this_position + Vector2i.UP, this_position + Vector2i.RIGHT, this_position + Vector2i.DOWN])


# join ports to all neighboring regions
func join_ports():
    for region in regions.get_child_count():
        for this_position in regions.get_by_id(region).positions:
            var group_name = terrain.group_names[terrain.get_position_group(this_position)]
            if group_name != 'port': continue
            # add all ports to all neighboring regions
            for neighbor_position in get_in_bounds_neighbors(this_position):
                var neighbor_regions = regions.by_position[neighbor_position]
                for neighbor_region in neighbor_regions:
                    regions.set_position(this_position, neighbor_region.id)


func set_regions():
    var this_position = Vector2i(0,0)
    var stack = [this_position]
    var current_region = -1
    var tile_group:int

    while not stack.is_empty():
        this_position = stack.pop_front()
        tile_group = terrain.get_position_group(this_position)

        if this_position not in regions.by_position:
            current_region += 1
            regions.set_position(this_position, current_region)

        for neighbor_position in get_in_bounds_neighbors(this_position):
            if neighbor_position in regions.by_position: continue

            var neighbor_group = terrain.get_position_group(neighbor_position)

            if neighbor_group == tile_group:
                regions.set_position(neighbor_position, current_region)
                stack.push_front(neighbor_position)
            else:
                stack.push_back(neighbor_position)
