extends Resource
class_name SavedCity

@export var my_team: String
@export var position: Vector2
@export var modulate: Color
@export var open: bool

# track this to make the save file easier to read
@export var _class_name: String

# how can I automatically add all properties during restore?
# the method to automate this uses `.get_property_list()`
# plus comparing property usage flags, which seems fragile and complex
# for now, set them manually
var automatic = ['my_team', 'position', 'modulate', 'open']

func save(city:City):
    for property in automatic:
        self[property] = city[property]
    self._class_name = 'SavedCity'

func restore(city:City):
    for property in automatic:
        city[property] = self[property]
