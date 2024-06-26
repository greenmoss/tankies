extends Node2D

@onready var terrain = $Terrain

# TODO: read names from the project settings
#var collider_names = {'1': 'barrier', '2': 'land', '4': 'ocean'}
#var region_types = {}

var regions:Array
var position_regions:Dictionary


func _ready():
    #set_source_tile_counts()
    #set_physics_layers_tiles()
    set_regions()
    join_ports()


#func get_collider_name(layer_id:int) -> String:
#    return ''


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


func join_ports():
    if regions.is_empty():
        set_regions()
    for region in regions.size():
        for this_position in regions[region]:
            var group_name = terrain.group_names[terrain.get_position_group(this_position)]
            if group_name != 'port': continue
            print("region ",region," has position count ",regions[region].size(), " and type ",group_name)
            # add port to all neighboring regions
            for neighbor_position in get_in_bounds_neighbors(this_position):
                var neighbor_region = position_regions[neighbor_position]
                print("adding to region ",neighbor_region)
                set_region(this_position, neighbor_region)


func set_region(this_position:Vector2i, region:int):
    #print("setting region for position ",this_position)
    position_regions[this_position] = region
    if region > regions.size():
        regions.append([])
    regions[region - 1].append(this_position)


func set_regions():
    #print("tile_groups: ",terrain.tile_groups)
    #print("physics_layers_tiles: ",terrain.physics_layers_tiles)
    #print("source tiles: ",terrain.source_tile_counts)

    regions = []
    position_regions = {}

    var this_position = Vector2i(0,0)
    #var neighbors:Array[Vector2i] = []
    var stack = [this_position]
    var current_region = 0
    var tile_group:int

    while not stack.is_empty():
        this_position = stack.pop_front()
        tile_group = terrain.get_position_group(this_position)

        if this_position not in position_regions:
            current_region += 1
            #print("at position ",this_position,", no region assigned, setting region ",current_region)
            set_region(this_position, current_region)

        #neighbors = get_neighbors(this_position)
        #print(neighbors)

        #for neighbor_position in neighbors:
        for neighbor_position in get_in_bounds_neighbors(this_position):
            if neighbor_position in position_regions: continue

            #print("at position ",this_position,", checking neighbor ",neighbor_position)
            var neighbor_group = terrain.get_position_group(neighbor_position)
            #print("at position ",this_position," group ",terrain.group_names[tile_group],", checking neighbor ",neighbor_position," group ",terrain.group_names[neighbor_group])

            if neighbor_group == tile_group:
                #print("neighbor and tile groups match, setting neighbor tile ",neighbor_position," region ",current_region)
                set_region(neighbor_position, current_region)
                stack.push_front(neighbor_position)
            else:
                stack.push_back(neighbor_position)

    #print("position regions: ",position_regions)
    #print("regions: ",regions.size())
    #for region in regions.size():
    #    print("region ",region," has position count ",regions[region].size())
