extends Sprite2D

var time = 0
var duration = 1.5  # length of the effect

func _process(delta):
    if not visible: return
    throb(delta)

func throb(delta):
    # animate alpha
    if time < duration:
        time += delta
        modulate.a = lerp(1.0, 0.25, time / duration)
    else:
        time = 0

func activate():
    if not visible:
        time = 0
    visible = true

func deactivate():
    visible = false