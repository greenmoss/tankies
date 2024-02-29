extends Node

var previous_turn_number : int
var turn_number : int
var start_next_turn : bool

# cities and teams are not in our node hierarchy
# so assign a connection via scene editor
@export var cities: Node
@export var teams: Node

func _ready():
    disable()
    previous_turn_number = -1
    turn_number = 0
    start_next_turn = true

func _physics_process(_delta):
    if(start_next_turn):
        start()
    else:
        check_done()

func start():
    start_next_turn = false

    previous_turn_number += 1
    turn_number += 1
    $banner.display(previous_turn_number, turn_number)

    cities.build_units()
    teams.start()

func check_done():
    if teams.are_done():
        end()

func enable():
    set_physics_process(true)

func end():
    start_next_turn = true

func disable():
    set_physics_process(false)

func stop():
    'stop checking for next turn, e.g. game is over'
    disable()
