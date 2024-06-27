extends Node
class_name Regions

var by_position:Dictionary
var region_scene = preload("region.tscn")


func _ready():
    by_position = {}
    for child in get_children():
        child.queue_free()


func add(region:int):
    var new_region = region_scene.instantiate()
    new_region.set_id(region)
    add_child(new_region)


func get_by_id(region:int) -> Region:
    if get_child_count() <= region: return null
    return get_child(region)


func set_position(this_position:Vector2i, region:int):
    if get_child_count() <= region:
        add(region)
    get_by_id(region).add_position(this_position)

    if this_position not in by_position:
        var new_regions:Array[Region] = []
        by_position[this_position] = new_regions
    var region_obj:Region = get_by_id(region)
    if not region_obj in by_position[this_position]:
        by_position[this_position].append(region_obj)


func set_terrain(terrain:Terrain):
    for child in get_children():
        child.terrain_id = terrain.get_position_group(child.positions[0])
        child.terrain_type = terrain.group_names[child.terrain_id]
