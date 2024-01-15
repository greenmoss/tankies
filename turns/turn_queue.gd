# from
# https://www.youtube.com/watch?v=FV4JkwI4OF4&list=PLhqJJNjsQ7KHaAQcGij5SmOPpFjrDTHUq&index=3&t=312s
extends Node2D

var unit_queue

func _ready():
    unit_queue = set_unit_queue()

func set_unit_queue():
    unit_queue = []
    for unit in get_children():
        if not unit.has_more_moves(): continue
        unit_queue.append(unit)
    print(unit_queue)

func take_turn():
    for unit in unit_queue:
        unit.take_turn()
