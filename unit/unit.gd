extends Area2D

var tile_size = 80
var inputs = {
    "right": Vector2.RIGHT,
    "left": Vector2.LEFT,
    "up": Vector2.UP,
    "down": Vector2.DOWN,
    }
var selected = false
var mouse_is_over_me = false
var animation_speed = 10
var moving = false

@export var unit_name = "Me"

@onready var ray = $RayCast2D

func _ready():
    position = position.snapped(Vector2.ONE * tile_size)
    position += Vector2.ONE * tile_size/2

func _unhandled_input(event):
    if not selected: return
    if moving: return
    for direction in inputs.keys():
        if event.is_action_pressed(direction):
            move(direction)

func move(direction):
    ray.target_position = inputs[direction] * tile_size
    ray.force_raycast_update()
    if ray.is_colliding():
        if $Sounds/Move.playing:
            $Sounds/Move.stop()
        if not $Sounds/Denied.playing:
            $Sounds/Denied.play()
    else:
        if not ($Sounds/Move.playing):
            $Sounds/Ack.play()
            $Sounds/Move.play()

        var tween = create_tween()
        tween.tween_property(self, "position",
            position +
            inputs[direction] *
            tile_size,
            1.0/animation_speed
            ).set_trans(Tween.TRANS_SINE)
        moving = true
        await tween.finished
        moving = false



func _on_mouse_entered():
    mouse_is_over_me = true

func _on_mouse_exited():
    mouse_is_over_me = false

func _input(event):
    if event.is_action_pressed("click"):
        if mouse_is_over_me: select_me()
        else: deselect_me()

func select_me():
    if not ($Sounds/Ready.playing):
        $Sounds/Ready.play()
    selected = true

func deselect_me():
    selected = false
