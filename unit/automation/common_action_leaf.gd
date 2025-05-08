@tool
extends ActionLeaf


# for debugging, log search perimeter as ascii table
func debug_perimeter(actor:Unit, blackboard:Blackboard, perimeter:Array[Vector2]):
    var terrain = blackboard.get_value("terrain")
    push_warning("perimeter is ",perimeter)
    var x_str = ' '
    for x in terrain.x_max:
        x_str += ' ' + str(x % 10)
    push_warning(x_str)
    for y in terrain.y_max:
        var row = str(y % 10)
        for x in terrain.x_max:
            var this_position = Vector2(x,y)
            if this_position in perimeter:
                row += ' .'
                continue

            var this_position_i = Vector2i(x,y)
            if this_position_i == actor.get_world_position():
                row += ' U'
                continue

            row += '  '
        row += '|'
        push_warning(row)
    push_warning('')


func get_unexplored_perimeter(actor:Unit, search_radius:int, explored:Dictionary, region:Region) -> Array[Vector2]:
    var center = actor.get_world_position()
    var x_first = center.x - search_radius
    var x_last =  center.x + search_radius + 1
    var y_first = center.y - search_radius
    var y_last =  center.y + search_radius + 1

    var region_min_x = region.min_bound.x
    # TODO: investigate off-by-one, maybe call as function if these "+1" are needed
    var region_max_x = region.max_bound.x + 1
    var region_min_y = region.min_bound.y
    var region_max_y = region.max_bound.y + 1

    var coordinate:Vector2
    # TODO: fix off-by-one/mismatch here, then use only `coordinate` and delete `explored_coordinate`:
    var explored_coordinate:Vector2
    var perimeter:Array[Vector2] = []
    var x_range = range(x_first, x_last)
    for x in x_range:
        var y_range:Array
        # for first/last row, include all y coordinates
        if (x == x_first) or (x == (x_last - 1)):
            y_range = range(y_first, y_last)
        # for all other rows, include only first/last y coordinates
        else:
            y_range = [ y_first, y_last - 1 ]
        for y in y_range:
            if x < region_min_x:
                continue
            if x > region_max_x:
                continue
            if y < region_min_y:
                continue
            if y > region_max_y:
                continue

            coordinate = Vector2(x, y)

            explored_coordinate = Vector2(x+1, y+1)
            if not explored_coordinate in explored:
                continue
            if explored[explored_coordinate] == true:
                continue

            perimeter.append(coordinate)

    return perimeter
