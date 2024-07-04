extends Node2D
class_name Map

@onready var regions = $regions
@onready var terrain = $Terrain


func _ready():
    set_regions()


# for debugging, log regions as ascii table
func debug_regions():
    for y in terrain.y_max:
        var row = ''
        for x in terrain.x_max:
            row += str(regions.by_position[Vector2i(x,y)][-1].id)
            row += ' '
        push_warning(row)
    push_warning('')
    for y in terrain.y_max:
        var row = ''
        for x in terrain.x_max:
            row += str(regions.by_position[Vector2i(x,y)].size())
            row += ' '
        push_warning(row)
    push_warning('')


func get_in_bounds_neighbors(this_position) -> Array[Vector2i]:
    var neighbors:Array[Vector2i] = []
    for neighbor_position in get_neighbors(this_position):
        if neighbor_position.x > terrain.x_max: continue
        if neighbor_position.x < terrain.x_min: continue
        if neighbor_position.y > terrain.y_max: continue
        if neighbor_position.y < terrain.y_min: continue
        neighbors.append(neighbor_position)
    return(neighbors)


func get_neighbors(this_position) -> Array[Vector2i]:
    return(
        [
            this_position + Vector2i.LEFT,
            this_position + Vector2i.UP,
            this_position + Vector2i.RIGHT,
            this_position + Vector2i.DOWN
        ]
    )


# join ports to all neighboring regions
func join_ports():
    for region in regions.get_children():
        if region.terrain_type != 'port': continue
        for this_position in region.positions:
            for neighbor_position in get_in_bounds_neighbors(this_position):
                var neighbor_regions = regions.by_position[neighbor_position]
                for neighbor_region in neighbor_regions:
                    regions.set_position(this_position, neighbor_region.id)

        # join for this region is complete
        # remove this port region
        regions.remove(region)


# use "flood fill" algorithm
# connect adjacent coordinates that share the same physics layers
func set_regions():
    regions.clear()
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

    regions.set_terrain(terrain)
    join_ports()
