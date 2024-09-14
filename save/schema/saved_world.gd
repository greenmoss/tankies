extends Resource
class_name SavedWorld

@export var cities: Array[SavedCity]
@export var teams: Array[SavedTeam]
@export var terrain: SavedTerrain

# properties below must be set by editing the scenario file
@export var name: String
@export var objective: String

func get_information() -> Dictionary:
    return({'name': name, 'objective': objective, 'file_name': self.resource_path.get_file()})

func save_city(city: City):
    var saved_city = SavedCity.new()
    saved_city.save(city)
    cities.append(saved_city)

func save_team(team: Team):
    var saved_team = SavedTeam.new()
    saved_team.save(team)
    teams.append(saved_team)

func save_terrain(previous_terrain: Terrain):
    var saved_terrain = SavedTerrain.new()
    saved_terrain.save(previous_terrain)
    terrain = saved_terrain
