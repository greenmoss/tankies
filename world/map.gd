extends Node2D

@onready var terrain = $Terrain

var regions:Array
var position_regions:Dictionary


func _ready():
    set_regions()
    join_ports()


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
    if regions.is_empty():
        set_regions()
    for region in regions.size():
        for this_position in regions[region]:
            var group_name = terrain.group_names[terrain.get_position_group(this_position)]
            if group_name != 'port': continue
            # add all ports to all neighboring regions
            for neighbor_position in get_in_bounds_neighbors(this_position):
                var neighbor_regions = position_regions[neighbor_position]
                for neighbor_region in neighbor_regions:
                    set_region(this_position, neighbor_region)


func set_region(this_position:Vector2i, region:int):
    if this_position not in position_regions:
        var new_regions:Array[int] = []
        position_regions[this_position] = new_regions
    if not region in position_regions[this_position]:
        position_regions[this_position].append(region)

    if region > regions.size() - 1:
        regions.append([])
    regions[region].append(this_position)


func set_regions():
    regions = []
    position_regions = {}

    var this_position = Vector2i(0,0)
    var stack = [this_position]
    var current_region = -1
    var tile_group:int

    while not stack.is_empty():
        this_position = stack.pop_front()
        tile_group = terrain.get_position_group(this_position)

        if this_position not in position_regions:
            current_region += 1
            set_region(this_position, current_region)

        for neighbor_position in get_in_bounds_neighbors(this_position):
            if neighbor_position in position_regions: continue

            var neighbor_group = terrain.get_position_group(neighbor_position)

            if neighbor_group == tile_group:
                set_region(neighbor_position, current_region)
                stack.push_front(neighbor_position)
            else:
                stack.push_back(neighbor_position)
