extends Resource
class_name SavedTeam

# for now we statically assign teams within the world scene
# we are only tracking team units for red and green teams
@export var saved_units: Array[SavedUnit]
@export var name: String

# track this to make the save file easier to read
@export var _class_name: String

func save(team:Team):
    name = team.name
    for unit in team.units.get_children():
        var saved_unit = SavedUnit.new()
        saved_unit.save(unit)
        saved_units.append(saved_unit)
    self._class_name = 'SavedTeam'

# we restore directly in the teams node
#func restore(units:Units):
