extends Node2D

@onready var progress = $progress
@onready var turns_remaining = $turns_margin/turns_remaining

var progress_max = 50.0
var progress_min = 0.0
var progress_animation_time = 0.0
var progress_animation_duration = 1.5
var progress_animation_pause = 0.5

var default_display_text = "Turns: "
var default_tooltip_text = "Turns until built: "


func _physics_process(delta):
    progress_animation_time += delta
    if progress_animation_time > (progress_animation_duration + progress_animation_pause):
       progress_animation_time = 0.0

    if progress_animation_time <= progress_animation_duration:
        progress.value = lerp(progress_min, progress_max, progress_animation_time / progress_animation_duration)
    else:
        progress.value = progress_max


func exit():
    progress_animation_time = 0.0
    set_physics_process(false)


func set_from_city(city:City):
    progress.modulate = city.icon.modulate

    progress_min = (float(city.build_duration) - float(city.build_remaining)) / float(city.build_duration) * 100.0
    progress_max = (float(city.build_duration) - float(city.build_remaining) + 1.0) / float(city.build_duration) * 100.0
    turns_remaining.text = str(city.build_remaining)
    progress.tooltip_text = default_tooltip_text+str(city.build_remaining)
    turns_remaining.text = default_display_text+str(city.build_remaining)
    turns_remaining.tooltip_text = default_tooltip_text+str(city.build_remaining)
    set_physics_process(true)
