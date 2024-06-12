extends Node2D

signal damaged
signal destroyed

var impact1 : AnimatedSprite2D
var impact2 : AnimatedSprite2D
var impact3 : AnimatedSprite2D
var delay1 : Timer
var delay2 : Timer
var delay3 : Timer
var blows_up : bool
var cease_fire : bool
var boundary : int # x and y boundary of random impacts

func _ready():
    randomize()
    blows_up = false
    cease_fire = true
    boundary = int(floor(float(Global.tile_size) / 2))
    impact1 = $bullet_spray/impact1
    delay1 = $bullet_spray/impact1/delay
    impact2 = $bullet_spray/impact2
    delay2 = $bullet_spray/impact2/delay
    impact3 = $bullet_spray/impact3
    delay3 = $bullet_spray/impact3/delay


func _on_countdown_timeout():
    cease_fire = true
    $bullet_spray.hide()
    damaged.emit()

    if blows_up:
        destroy()


func _on_impact_1_animation_finished():
    await random_wait(delay1)
    random_impact(impact1)


func _on_impact_2_animation_finished():
    await random_wait(delay2)
    random_impact(impact2)


func _on_impact_3_animation_finished():
    await random_wait(delay3)
    random_impact(impact3)


func destroy():
    destroyed.emit()
    $explosion.show()
    $explosion.play()
    await $explosion.animation_finished
    $explosion.hide()


func random_wait(delay):
    if cease_fire: return
    delay.set_wait_time(randf_range(0.02, 0.2))
    delay.start()
    await delay.timeout


func random_impact(impact):
    if cease_fire: return
    impact.hide()
    impact.position = Vector2(randi() % boundary - 20, randi() % boundary - 20)
    impact.rotation = randi() % 360
    var random_scale = randf_range(0.1, 0.5)
    impact.scale = Vector2(random_scale, random_scale)
    impact.show()
    impact.play()


func take_fire(bad_day : bool):
    if bad_day:
        blows_up = true
    else:
        blows_up = false
    cease_fire = false
    $countdown.start()
    $bullet_spray.show()
    random_impact(impact1)
    random_impact(impact2)
    random_impact(impact3)
