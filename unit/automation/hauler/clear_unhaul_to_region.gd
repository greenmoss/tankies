@tool
extends ActionLeaf


func tick(_actor, blackboard):
    var path_to_unhaul:PackedVector2Array = []
    blackboard.set_value('unhaul_to_region_path', path_to_unhaul)

    #print("set unhaul to region 1")

    return SUCCESS
