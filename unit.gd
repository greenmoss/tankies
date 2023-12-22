extends Area2D


func _on_mouse_entered():
    print("mouse entered")
    print(self)



func _on_input_event(viewport, event, shape_idx):
    if event.is_action_pressed("click"):
        print("clicked")
        var mouse_position = get_viewport().get_mouse_position()
