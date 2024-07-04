extends Node
class_name Regions

var by_position:Dictionary
var region_scene = preload("region.tscn")


func _ready():
    clear()


func add(region:int):
    var new_region = region_scene.instantiate()
    new_region.set_id(region)
    add_child(new_region)


func clear():
    by_position = {}
    for child in get_children():
        child.queue_free()
        remove(child)


func get_by_id(region:int) -> Region:
    if get_child_count() <= region: return null
    return get_child(region)


func get_from_position(this_position:Vector2i) -> Array[Region]:
    return by_position[this_position]


func get_from_unit(unit:Unit) -> Region:
    var world_position = unit.get_world_position()
    var unit_regions = get_from_position(world_position)
    for region in unit_regions:
        # TODO: refactor node validity checks
        # if the world moves to FSM, perhaps these will no longer be needed
        if region == null: continue
        if not is_instance_valid(region): continue
        if region.is_queued_for_deletion(): continue
        # if unit colliders "hit" region colliders, that region is incompatible with the unit
        if (unit.get_colliders() & region.colliders) != 0: continue
        return region
    # no compatible regions found
    return null


func remove(region:Region):
    for this_position in by_position.keys():
        if region not in by_position[this_position]: continue
        by_position[this_position].erase(region)

    region.queue_free()
    remove_child(region)


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
        child.colliders = terrain.get_physics_colliders(child.terrain_id)
        child.terrain_type = terrain.group_names[child.terrain_id]
