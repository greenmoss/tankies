extends Node
class_name Cities

var city_scene : PackedScene = preload("res://city/city.tscn")


func build_units():
    # only human and ai cities build units, not neutral
    for city in make_team_queue(Global.human_team):
        city.build_unit()
    for city in make_team_queue(Global.ai_team):
        city.build_unit()


# this checks for cardinal distance on the map
# terrain and obstacles are *NOT* considered
func get_all_by_cardinal_distance(position:Vector2) -> Dictionary:
    var distance_map = {}
    for city in get_children():
        var distance: float = position.distance_to(city.position)
        if distance not in distance_map:
            distance_map[distance] = []
        distance_map[distance].append(city)
    return(distance_map)


func get_from_team(team_name:String) -> Array[City]:
    var cities:Array[City] = []
    for city in get_children():
        if city.my_team != team_name: continue
        cities.append(city)
    return cities


func make_team_queue(team_name):
    var team_queue = []
    for city in get_children():
        if city.my_team != team_name: continue
        team_queue.append(city)
    return(team_queue)


func tally_owners():
    var team_owners = {}
    for city in get_children():
        if team_owners.get(city.my_team) == null:
            team_owners[city.my_team] = 0
        team_owners[city.my_team] += 1
    return(team_owners)


func restore(saved_cities):
    for city in get_children():
        self.remove_child(city)
        city.queue_free()

    if(saved_cities.is_empty()): return

    var city_template = city_scene.instantiate()

    for saved_city in saved_cities:
        var city = city_template.duplicate()
        saved_city.restore(city)
        add_child(city)

    city_template.queue_free()


func save(saved: SavedWorld):
    for city in get_children():
        saved.save_city(city)
