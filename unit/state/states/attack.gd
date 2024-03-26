extends "res://common/state.gd"

func enter():
    print("in state:move enter")
    #owner.get_node(^"AnimationPlayer").play("idle")


#func _on_Sword_attack_finished():
#    emit_signal("finished", "previous")
