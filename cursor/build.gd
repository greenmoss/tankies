extends Node2D

@onready var progress = $progress
@onready var selector = $selector
@onready var turns_remaining = $turns_remaining

var progress_max = 50.0
var progress_min = 0.0
var progress_animation_time = 0.0
var progress_animation_duration = 1.5
var progress_animation_pause = 0.5

var default_tooltip_text = " days to build"


func _physics_process(delta):
    progress_animation_time += delta
    if progress_animation_time > (progress_animation_duration + progress_animation_pause):
       progress_animation_time = 0.0

    if progress_animation_time <= progress_animation_duration:
        progress.value = lerp(progress_min, progress_max, progress_animation_time / progress_animation_duration)
    else:
        progress.value = progress_max


func disable_select():
    selector.visible = false


func set_idle():
    progress_animation_time = 0.0
    set_physics_process(false)


func set_from_city(city:City):
    progress.modulate = city.icon.modulate

    var unit:Unit = UnitTypeUtilities.get_type(city.build_type)

    progress_min = (float(city.build_duration) - float(city.build_remaining)) / float(city.build_duration) * 100.0
    progress_max = (float(city.build_duration) - float(city.build_remaining) + 1.0) / float(city.build_duration) * 100.0
    progress.tooltip_text = city.build_type
    progress.texture_under = unit.display.icon.texture
    progress.texture_progress = unit.display.icon.texture

    # animate the build progress dial
    set_physics_process(true)

    turns_remaining.text = str(city.build_remaining)
    turns_remaining.tooltip_text = str(city.build_remaining)+default_tooltip_text

    selector.tooltip_text = "Click to change build type"


func set_from_type(city:City, type:String):
    progress.modulate = city.icon.modulate

    var unit:Unit = UnitTypeUtilities.get_type(type)

    progress.value = 100.0
    progress.texture_under = unit.display.icon.texture
    progress.texture_progress = unit.display.icon.texture
    progress.tooltip_text = type

    # do not animate the build progress dial
    set_physics_process(false)

    turns_remaining.text = str(unit.build_time)
    turns_remaining.tooltip_text = str(unit.build_time)+default_tooltip_text

    selector.tooltip_text = "Click to change build to "+type
    selector.pressed.connect(_selector_pressed.bind(city, type))


func _selector_pressed(city:City, type:String):
    city.change_build_type(type)
