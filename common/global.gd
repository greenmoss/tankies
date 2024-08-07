extends Node

const tile_size = 80
const half_tile_size = 40

const ai_team = "RedTeam"
const human_team = "GreenTeam"

const team_colors = {
    "NoTeam": Color(1, 1, 1, 1),
    "GreenTeam": Color(0, 0.862745, 0, 1),
    "RedTeam": Color(1, 0.247059, 0.188235, 1),
}

# specify all custom z-layers here
# keeps them organized and in order
const z_layers = [
    'default', # for reference only
    'stack_lid', # team/stack_lid
    'cursor', # all cursor elements
    'battle', # explosions, etc
    'fog', # for unexplored/un-seen terrain
    'units', # pop-up window showing list of units
    'turn_banner', # end of turn pop-up
    'tint', # end of game fading window
]

enum Controllers {AI, HUMAN, NONE}


func as_grid(position:Vector2) -> Vector2i:
    var grid_x = int(float(position.x) / float(tile_size))
    var grid_y = int(float(position.y) / float(tile_size))
    return(Vector2i(grid_x, grid_y))


func as_position(grid:Vector2i) -> Vector2:
    var position_x = (grid.x * tile_size) + half_tile_size
    var position_y = (grid.y * tile_size) + half_tile_size
    return(Vector2i(position_x, position_y))


func set_z(object:Node, z_name:String):
    var new_z = z_layers.find(z_name)
    if new_z == -1:
        push_warning("there is no z_layer named ",z_name,"; ignoring")
        return
    object.z_index = new_z
