extends TileMap

# The positive Vector2i correspond to fog tilemap atlas coordinates
var states = {
    'unexplored': Vector2i(0,0),
    'unseen': Vector2i(0,1),
    'visible': Vector2i(-1,-1),
    }
var tile_layer = 0
var tile_source = 0
var space_state
var query
var were_seen = {}
var snapshot

@onready var phantoms = $phantoms
@onready var phantom_template = $phantoms/template


func _ready():
    if owner.show_fog:
        visible = true
    # TODO: figure out how to disconnect signal
    space_state = get_world_2d().get_direct_space_state()
    query = PhysicsPointQueryParameters2D.new()
    query.set_collide_with_areas(true)


func _on_vision_derived():
    if not visible: return
    if owner.vision == null: return
    if owner.terrain == null: return
    for explored_coordinate in owner.vision.explored.keys():
        var is_explored = owner.vision.explored[explored_coordinate]
        # we are offset by one, not sure why
        var local_coordinate = Vector2i(explored_coordinate.x - 1, explored_coordinate.y - 1)
        if is_explored:
            if owner.vision.visible.has(explored_coordinate):
                set_seen(local_coordinate)
            #else:
            #    set_unseen(local_coordinate)
        else:
            set_cell(tile_layer, local_coordinate, tile_source, states['unexplored'])


func set_seen(local_coordinate):
    were_seen.erase(local_coordinate)

    set_cell(tile_layer, local_coordinate, tile_source, states['visible'])


func set_unseen(local_coordinate):
    if were_seen.has(local_coordinate): return

    set_cell(tile_layer, local_coordinate, tile_source, states['unseen'])
    var global_coordinate = Vector2i(local_coordinate.x * 80, local_coordinate.y * 80)
    query.position = Vector2i(global_coordinate.x, global_coordinate.y)
    var intersects = space_state.intersect_point(query)
    print("intersects: ",intersects)

    were_seen[local_coordinate] = true
