extends Resource
class_name SavedUnit

@export var my_team:String
@export var position:Vector2
@export var modulate:Color

# track this to make the save file easier to read
@export var _class_name: String

# how can I automatically add all properties during restore?
# the method to automate this uses `.get_property_list()`
# plus comparing property usage flags, which seems fragile and complex
# for now, set them manually
var automatic = ['my_team', 'position']

func save(unit:Unit):
    for property in automatic:
        self[property] = unit[property]
    self._class_name = 'SavedUnit'

func restore(unit:Unit):
    for property in automatic:
        unit[property] = self[property]
