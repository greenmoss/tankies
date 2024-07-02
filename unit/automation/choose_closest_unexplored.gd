extends ActionLeaf


func tick(actor, blackboard):
    var regions = blackboard.get_value("regions")
    var this_region = regions.get_from_unit(actor)
    var max_search_radius = this_region.get_max_distance()
    #var max_search_radius = get_terrain_max_size(blackboard)

    blackboard.set_value("exploration_path", null)

    for search_radius in range(actor.vision.distance + 1, max_search_radius + 1):
        set_exploration_path(actor, search_radius, blackboard)
        if blackboard.get_value("exploration_path") != null:
            blackboard.set_value("move_position", blackboard.get_value("exploration_path")[1])
            return SUCCESS

    return FAILURE


func get_terrain_max_size(blackboard:Blackboard) -> int:
    var terrain = blackboard.get_value("terrain")
    var width = terrain.get_used_rect().size.x
    var height = terrain.get_used_rect().size.y
    if height > width:
        return height
    return width


func set_exploration_path(actor:Unit, search_radius:int, blackboard:Blackboard):
    var center = actor.vision.convert_from_world_position(actor.position)
    var terrain = blackboard.get_value("terrain")

    var perimeter:Array[Vector2] = get_unexplored_perimeter(actor, search_radius, blackboard)
    print("choose closest unexplored perimeter is ",perimeter)
    randomize()
    perimeter.shuffle()
    for coordinate in perimeter:
        var path = terrain.find_coordinate_path(center, coordinate)
        if path.is_empty(): continue
        print("path to coordinate ",coordinate," is ",path)
        #REF
        #if path.size() <= (actor.vision.distance + 1):
        #    push_warning("got a path size ",path.size()," which should not happen; ignoring this path")
        #    continue
        # remove last path element, since we want to consider only known terrain
        path.remove_at(path.size() - 1)
        if not terrain.is_point_walkable(path[-1]):
            continue
        blackboard.set_value("exploration_path", path)
        return


func get_unexplored_perimeter(actor:Unit, search_radius:int, blackboard:Blackboard) -> Array[Vector2]:
    var center = actor.get_world_position()
    #REF
    #var center = actor.vision.convert_from_world_position(actor.position)
    var x_first = center[0] + (-1 * search_radius)
    var x_last = x_first + (search_radius * 2) + 1
    var y_first = center[1] + (-1 * search_radius)
    var y_last = y_first + (search_radius * 2) + 1

    var explored = blackboard.get_value("explored")
    var terrain = blackboard.get_value("terrain")
    var terrain_rect = terrain.get_used_rect()
    var terrain_min_x = 1                   + terrain_rect.position.x + actor.vision.distance
    var terrain_max_x = terrain_rect.size.x + terrain_rect.position.x - actor.vision.distance
    var terrain_min_y = 1                   + terrain_rect.position.y + actor.vision.distance
    var terrain_max_y = terrain_rect.size.y + terrain_rect.position.y - actor.vision.distance

    var coordinate:Vector2
    var unexplored:Array[Vector2] = []
    for x in range(x_first, x_last):
        var y_range:Array
        if (x == x_first) or (x == (x_last - 1)):
            y_range = range(y_first, y_last)
        else:
            y_range = [ y_first, y_last - 1 ]
        for y in y_range:
            coordinate = Vector2(x, y)
            if not coordinate in explored: continue
            if explored[coordinate] == true: continue
            # offset min/max x and y by unit view distance
            if x < terrain_min_x: continue
            if x > terrain_max_x: continue
            if y < terrain_min_y: continue
            if y > terrain_max_y: continue
            unexplored.append(coordinate)
    return unexplored
