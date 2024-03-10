extends Resource
class_name SavedWorld

@export var cities: Array[SavedCity]
@export var teams: Array[SavedTeam]
@export var terrain: Array

# properties below must be set by editing the scenario file
@export var objective: String

func save_city(city: City):
    var saved_city = SavedCity.new()
    saved_city.save(city)
    cities.append(saved_city)

func save_team(team: Team):
    var saved_team = SavedTeam.new()
    saved_team.save(team)
    teams.append(saved_team)

