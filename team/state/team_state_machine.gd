extends "res://common/state_machine.gd"

@onready var ai_plan = $ai_plan
@onready var begin = $begin
@onready var end = $end
@onready var human_begin = $human_begin
@onready var human_plan = $human_plan
@onready var move = $move
@onready var plan = $plan
@onready var wait = $wait


func _ready():

    states_map = {
        "begin": begin,
        "end": end,
        "move": move,
        "plan": plan,
        "wait": wait,
    }

    match owner.controller:
        Global.Controllers.AI:
            states_map['plan'] = ai_plan
        Global.Controllers.HUMAN:
            states_map['begin'] = human_begin
            states_map['plan'] = human_plan


func _change_state(state_name):
    if not _active:
        return
    super._change_state(state_name)
