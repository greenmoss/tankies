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
var facing = 0 # default/right

signal unit_collided

@export var unit_name = "Me"

@onready var ray = $RayCast2D

func _ready():
    position = position.snapped(Vector2.ONE * tile_size / 2)

func _unhandled_input(event):
    if not selected: return
    if moving: return
    for direction in inputs.keys():
        if event.is_action_pressed(direction):
            try_to_move(direction)

func try_to_move(direction):
    ray.target_position = inputs[direction] * tile_size
    ray.force_raycast_update()
    if ray.is_colliding():
        emit_signal("unit_collided", self, ray.get_collider())
        deny_move()
    else:
        move(direction)

func face_toward(direction):
    if(direction == "right"):
        $Sprite2D.flip_h = false
        return
    if(direction == "left"):
        $Sprite2D.flip_h = true
        return

func move(direction):
    play_move_sound()
    face_toward(direction)

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

func play_move_sound():
    if not ($Sounds/Move.playing):
        $Sounds/Ack.play()
        $Sounds/Move.play()


func _on_mouse_entered():
    mouse_is_over_me = true

func _on_mouse_exited():
    mouse_is_over_me = false

func _input(event):
    if event.is_action_pressed("click"):
        if mouse_is_over_me: select_me()
        else: deselect_me()

func deny_move():
    if $Sounds/Move.playing:
        $Sounds/Move.stop()
    if not $Sounds/Denied.playing:
        $Sounds/Denied.play()

func select_me():
    if not ($Sounds/Ready.playing):
        $Sounds/Ready.play()
    selected = true

func deselect_me():
    selected = false
