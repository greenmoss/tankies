extends Node
class_name Region

var id:int
var colliders:int # collision layers: what unit types can traverse this region
var approaches:Array[Vector2i]
var approach_segments:Array
var positions:Array[Vector2i]
var terrain_id:int
var terrain_type:String
var max_bound:Vector2i
var min_bound:Vector2i


func _ready():
    approach_segments = []
    positions = []
    # can not be null, so use opposite max/min instead
    max_bound = Vector2i.MIN
    min_bound = Vector2i.MAX


func add_approach(new_position:Vector2i):
    if new_position in approaches: return
    approaches.append(new_position)


func add_position(new_position:Vector2i):
    if new_position in positions: return
    positions.append(new_position)
    if new_position.x > max_bound.x:
        max_bound.x = new_position.x
    if new_position.y > max_bound.y:
        max_bound.y = new_position.y
    if new_position.x < min_bound.x:
        min_bound.x = new_position.x
    if new_position.y < min_bound.y:
        min_bound.y = new_position.y


func get_approach_position(approach_positions:PackedVector2Array) -> Vector2:
    for segment in approach_segments:
        for approach_position in approach_positions:
            if Global.as_grid(approach_position) in segment:
                return approach_position

    # not found, which could mean we missed the overlap due to diagonal movement
    # so search neighbors of each approach position
    for segment in approach_segments:
        for approach_position in approach_positions:
            var approach_point = Global.as_grid(approach_position)
            for neighbor_point in get_segment_neighbors(approach_point):
                if neighbor_point in segment:
                    return Global.as_position(neighbor_point)

    # since active units on map are always on a positive position
    # return negative vector as the equivalend of `null`
    return Vector2.LEFT


func get_approach_neighbors(approach_point:Vector2i) -> Array[Vector2i]:
    var approach_segment:Array[Vector2i] = []
    var point_index = -1
    for segment in approach_segments:
        point_index = segment.find(approach_point)
        if point_index == -1: continue
        approach_segment = segment
        break

    var approach_neighbors:Array[Vector2i] = []

    # point not found, so there are no neighbors
    if point_index == -1:
        return approach_neighbors

    # 1, 2, or 3 points; remove the approach point and the rest must be neighbors
    if approach_segment.size() <= 3:
        approach_neighbors = approach_segment
        approach_neighbors.erase(approach_point)
        return approach_neighbors

    var wrap_neighbor_candidates = get_segment_neighbors(approach_point)

    # first element, so second element is one neighbor
    if point_index == 0:
        approach_neighbors.append(approach_segment[1])

        # is last element also a neighbor?
        if approach_segment[-1] in wrap_neighbor_candidates:
            approach_neighbors.append(approach_segment[-1])

    # last element, so second-to-last element is one neighbor
    elif point_index == approach_segment.size() + 1:
        approach_neighbors.append(approach_segment[-2])

        # is firsst element also a neighbor?
        if approach_segment[0] in wrap_neighbor_candidates:
            approach_neighbors.append(approach_segment[0])

    else:
        approach_neighbors.append(approach_segment[point_index - 1])
        approach_neighbors.append(approach_segment[point_index + 1])

    return approach_neighbors


func get_max_distance() -> int:
    var size_x = max_bound.x - min_bound.x
    var size_y = max_bound.y - min_bound.y
    if size_x <= 0 or size_y <= 0:
        return 0
    if size_x > size_y:
        return size_x
    return size_y


func get_segment_neighbors(point:Vector2i) -> Array[Vector2i]:
    return [
        point + Vector2i.UP,
        point + Vector2i.RIGHT,
        point + Vector2i.DOWN,
        point + Vector2i.LEFT,
        # also consider diagonal connections
        point + Vector2i.UP + Vector2i.RIGHT,
        point + Vector2i.DOWN + Vector2i.RIGHT,
        point + Vector2i.DOWN + Vector2i.LEFT,
        point + Vector2i.UP + Vector2i.LEFT,
        ]


# convert approach coordinates into segments
# thus any unit approaching the region
# can follow a "ring" around the region
func segment_approaches():
    #print("region ",self," approaches: ",approaches)
    var unassigned = approaches.slice(1)
    var segment:Array[Vector2i] = [approaches[0]]

    for assign_count in approaches.size():
        #print("assigning, round ",assign_count)
        if unassigned.is_empty():
            #print("adding approach segment: ",segment)
            approach_segments.append(segment)
            break

        var assigned_any = false

        var first_point_neighbors = get_segment_neighbors(segment[0])
        for neighbor_point in first_point_neighbors:
            if not neighbor_point in unassigned: continue
            unassigned.erase(neighbor_point)
            segment.push_front(neighbor_point)
            assigned_any = true
            break

        var last_point_neighbors = get_segment_neighbors(segment[-1])
        for neighbor_point in last_point_neighbors:
            if not neighbor_point in unassigned: continue
            unassigned.erase(neighbor_point)
            segment.push_back(neighbor_point)
            assigned_any = true
            break

        if not assigned_any:
            #print("adding approach segment: ",segment)
            approach_segments.append(segment)
            segment = [unassigned[0]]
            unassigned.pop_front()

    #print("approach segments: ",approach_segments)
    #print("unassigned: ",unassigned)


func set_id(new_id:int):
    id = new_id
    name = 'region'+str(id)
