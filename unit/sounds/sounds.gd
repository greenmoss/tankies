extends Node
class_name UnitSounds

@onready var denied_sound = $Denied
@onready var move_sound = $Move
@onready var ready_sound = $Ready


func play_denied():
    stop_all()
    SoundManager.interrupt_channel("unit_denied", denied_sound)


func play_move():
    SoundManager.interrupt_channel("unit_moved", move_sound)


func play_ready():
    SoundManager.interrupt_channel("unit_is_ready", ready_sound)


func stop_all():
    SoundManager.stop_all(["unit_moved", "unit_denied", "unit_is_ready"])
